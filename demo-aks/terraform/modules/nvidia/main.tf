resource "helm_release" "nvidia_device_plugin" {
  name             = var.name
  repository       = "https://nvidia.github.io/k8s-device-plugin"
  chart            = "nvidia-device-plugin"
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = true

  values = [
    "${templatefile("${path.module}/nvidia-device-plugin-values.tftpl", {
      tag = var.image_tag
    })}"
  ]
}
