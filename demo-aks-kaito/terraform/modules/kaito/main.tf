locals {
  model-name = lower(replace(var.kaito_ai_model, "/[\\\\]|[^a-zA-Z0-9-]/", "--")) # Ensure Azure resource naming compliance. Any `\` is replaced with `--`
}

data "azurerm_subscription" "current" {
}

data "azurerm_user_assigned_identity" "kaito_identity" {
  name                = var.kaito_identity_name
  resource_group_name = var.kaito_identity_resource_group_name
}

resource "azurerm_role_assignment" "kaito_provisioner_assigned_identity_contributor_role" {
  principal_id                     = data.azurerm_user_assigned_identity.kaito_identity.principal_id
  scope                            = var.aks_id
  role_definition_name             = "Contributor"
  skip_service_principal_aad_check = true
}

resource "kubernetes_namespace" "kaito_namespace" {
  metadata {
    name = var.kaito_aks_namespace
  }
}

resource "azurerm_federated_identity_credential" "kaito_gpu_provisioner_federated_identity_credential" {
  name                = "kaito-gpu-provisioner-federated-id"
  resource_group_name = data.azurerm_user_assigned_identity.kaito_identity.resource_group_name
  parent_id           = data.azurerm_user_assigned_identity.kaito_identity.id
  issuer              = var.aks_oidc_issuer_url
  audience            = ["api://AzureADTokenExchange"]
  subject             = "system:serviceaccount:${kubernetes_namespace.kaito_namespace.metadata.0.name}:gpu-provisioner"
}

resource "helm_release" "kaito_workspace" {
  name             = "kaito-workspace"
  chart            = "https://raw.githubusercontent.com/kaito-project/kaito/refs/heads/gh-pages/charts/kaito/workspace-${var.kaito_workspace_version}.tgz"
  namespace        = kubernetes_namespace.kaito_namespace.metadata.0.name
  create_namespace = false
}

resource "helm_release" "gpu_provisioner" {
  name             = "kaito-gpu-provisioner"
  chart            = "https://raw.githubusercontent.com/Azure/gpu-provisioner/refs/heads/gh-pages/charts/gpu-provisioner-${var.gpu_provisioner_version}.tgz"
  namespace        = kubernetes_namespace.kaito_namespace.metadata.0.name
  create_namespace = false

  values = [
    templatefile("${path.module}/gpu-provisioner-values.tftpl",
      {
        AZURE_TENANT_ID          = data.azurerm_user_assigned_identity.kaito_identity.tenant_id
        AZURE_SUBSCRIPTION_ID    = data.azurerm_subscription.current.subscription_id
        RG_NAME                  = var.resource_group_name
        LOCATION                 = var.aks_location
        AKS_NAME                 = var.aks_name
        AKS_NRG_NAME             = var.aks_node_resource_group_name
        KAITO_IDENTITY_CLIENT_ID = data.azurerm_user_assigned_identity.kaito_identity.client_id
      }
    )
  ]
}

locals {
  kaito_ai_model_workspace_name = "workspace-kaito-model-${local.model-name}"
}

resource "kubectl_manifest" "kaito_ai_model_workspace_deployment" {
  yaml_body = <<-EOF
    apiVersion: kaito.sh/v1alpha1
    kind: Workspace
    metadata:
      name: ${local.kaito_ai_model_workspace_name}
      namespace: ${kubernetes_namespace.kaito_namespace.metadata.0.name}
      annotations:
        kaito.sh/runtime: "transformers"
        kaito.sh/enablelb: "False"
    resource:
      count: 1
      instanceType: "${var.kaito_instance_type_vm_size}"
      labelSelector:
        matchLabels:
          apps: ${local.model-name}
    inference:
      template: 
        spec:
          containers:
          - name: container-${local.model-name}
            image: ghcr.io/kaito-project/kaito/llm-reference-preset:latest
            resources:
              requests:
                nvidia.com/gpu: 1
              limits:
                nvidia.com/gpu: 1
            command: ["accelerate"]
            args:
              - "launch"
              - "--num_processes"
              - "1"
              - "--num_machines"
              - "1"
              - "--gpu_ids"
              - "all"
              - "inference_api.py"
              - "--pipeline"
              - "conversational"
              - "--trust_remote_code"
              - "--allow_remote_files"
              - "--pretrained_model_name_or_path"
              - "${var.kaito_ai_model}"
              - "--torch_dtype"
              - "bfloat16"
            volumeMounts:
            - name: dshm
              mountPath: /dev/shm
          volumes:
          - name: dshm
            emptyDir:
              medium: Memory
    EOF

  depends_on = [
    helm_release.kaito_workspace,
    helm_release.gpu_provisioner
  ]
}

resource "azurerm_network_security_rule" "kaito_ai_model_inference_network_security_rule" {
  name                        = "rule-${var.kaito_aks_namespace}-${var.kaito_inference_port}"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = 80
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = var.network_security_group_name
}

resource "kubernetes_ingress_v1" "kaito_ai_model_inference_endpoint_ingress" {
  wait_for_load_balancer = true

  metadata {
    name      = "ingress-kaito-${local.model-name}"
    namespace = kubernetes_namespace.kaito_namespace.metadata.0.name
  }

  spec {
    ingress_class_name = "webapprouting.kubernetes.azure.com" # Remember we are using the webapp routing add-on
    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = local.kaito_ai_model_workspace_name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
