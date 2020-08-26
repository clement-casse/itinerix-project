resource "kubernetes_namespace" "app_ns" {
  metadata {
    name = "app"
    annotations = {
      "linkerd.io/inject" = "enabled"
    }
    labels = {
      istio-injection = "disabled"
    }
  }
}

resource "kubernetes_namespace" "monitoring_ns" {
  metadata {
    name = "monitoring"
    annotations = {
      "linkerd.io/inject" = "disabled"
    }
    labels = {
      istio-injection = "disabled"
    }
  }
}

resource "kubernetes_namespace" "grapher_ns" {
  metadata {
    name = "grapher"
    annotations = {
      "linkerd.io/inject" = "disabled"
    }
    labels = {
      istio-injection = "disabled"
    }
  }
}