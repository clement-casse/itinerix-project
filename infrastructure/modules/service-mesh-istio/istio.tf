resource "kubernetes_namespace" "istio_ns" {
  metadata {
    name = "istio-system"
    annotations = {
      "linkerd.io/inject" = "disabled"
    }
    labels = {
      istio-injection = "disabled"
    }
  }
}

data "kubectl_file_documents" "istio_base" {
  content = file("${path.module}/installation-manifests/Base/Base.yaml")
}

data "kubectl_file_documents" "istio_pilot" {
  content = file("${path.module}/installation-manifests/Base/Pilot/Pilot.yaml")
}

data "kubectl_file_documents" "istio_pilot_addons" {
  content = file("${path.module}/installation-manifests/Base/Pilot/AddonComponents/AddonComponents.yaml")
}

data "kubectl_file_documents" "istio_pilot_cni" {
  content = file("${path.module}/installation-manifests/Base/Pilot/Cni/Cni.yaml")
}

data "kubectl_file_documents" "istio_pilot_egress" {
  content = file("${path.module}/installation-manifests/Base/Pilot/EgressGateways/EgressGateways.yaml")
}

data "kubectl_file_documents" "istio_pilot_ingress" {
  content = file("${path.module}/installation-manifests/Base/Pilot/IngressGateways/IngressGateways.yaml")
}

data "kubectl_file_documents" "istio_pilot_policy" {
  content = file("${path.module}/installation-manifests/Base/Pilot/Policy/Policy.yaml")
}

data "kubectl_file_documents" "istio_pilot_telemetry" {
  content = file("${path.module}/installation-manifests/Base/Pilot/Telemetry/Telemetry.yaml")
}


resource "kubernetes_service" "istio_ingressgateway" {
  metadata {
    name      = "istio-ingressgateway"
    namespace = kubernetes_namespace.istio_ns.metadata.0.name
    labels = {
      "app"   = "istio-ingressgateway"
      "istio" = "ingressgateway"
      "release" = "istio"
    }
  }
  spec {
    type = "LoadBalancer"
    selector = {
      "app"   = "istio-ingressgateway"
      "istio" = "ingressgateway"
    }
    port {
      name        = "http"
      port        = 80
      target_port = 8000
    }
    port {
      name        = "https"
      port        = 443
      target_port = 4443
    }
    port {
      name        = "http-bolt"
      port        = 7687
      target_port = 7687
    }
    port {
      name        = "http-monitor"
      port        = 8888
      target_port = 8888
    }
  }
  depends_on = [kubernetes_namespace.istio_ns]
}

resource "kubectl_manifest" "istio_base" {
  count     = length(data.kubectl_file_documents.istio_base.documents)
  yaml_body = element(data.kubectl_file_documents.istio_base.documents, count.index)

  depends_on = [kubernetes_namespace.istio_ns]
}

resource "kubectl_manifest" "istio_pilot" {
  count     = length(data.kubectl_file_documents.istio_pilot.documents)
  yaml_body = element(data.kubectl_file_documents.istio_pilot.documents, count.index)

  depends_on = [kubectl_manifest.istio_base]
}

resource "kubectl_manifest" "istio_pilot_addons" {
  count     = length(data.kubectl_file_documents.istio_pilot_addons.documents)
  yaml_body = element(data.kubectl_file_documents.istio_pilot_addons.documents, count.index)

  depends_on = [kubectl_manifest.istio_pilot]
}

resource "kubectl_manifest" "istio_pilot_egress" {
  count     = length(data.kubectl_file_documents.istio_pilot_egress.documents)
  yaml_body = element(data.kubectl_file_documents.istio_pilot_egress.documents, count.index)

  depends_on = [kubectl_manifest.istio_pilot]
}

resource "kubectl_manifest" "istio_pilot_ingress" {
  count     = length(data.kubectl_file_documents.istio_pilot_ingress.documents)
  yaml_body = element(data.kubectl_file_documents.istio_pilot_ingress.documents, count.index)

  depends_on = [kubectl_manifest.istio_pilot]
}
