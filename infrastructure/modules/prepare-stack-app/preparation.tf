resource "kubernetes_namespace" "app_ns" {
  metadata {
    name = "app"
    annotations = {
      "linkerd.io/inject" = "enabled"
    }
    labels = {
      istio-injection = "enabled"
    }
  }
}
