resource "kubernetes_namespace" "prometheus_operator_ns" {
  metadata {
    name = "prometheus-system"
    annotations = {
      "linkerd.io/inject" = "disabled"
    }
    labels = {
      istio-injection = "disabled"
    }
  }
}

data "kubectl_file_documents" "strimzi_operator_manifests" {
  content = file("./kustomization/generated-manifest.yaml")
}

resource "kubectl_manifest" "strimzi_operator" {
  count     = length(data.kubectl_file_documents.strimzi_operator_manifests.documents)
  yaml_body = element(data.kubectl_file_documents.strimzi_operator_manifests.documents, count.index)

  depends_on = [kubernetes_namespace.strimzi_ns]
}