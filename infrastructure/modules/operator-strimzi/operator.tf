resource "kubernetes_namespace" "strimzi_ns" {
  metadata {
    name = "strimzi-system"
    annotations = {
      "linkerd.io/inject" = "disabled"
    }
    labels = {
      istio-injection = "disabled"
    }
  }
}

data "kubectl_file_documents" "strimzi_operator_manifests" {
  content = file("${path.module}/generated-manifests/operator.yaml")
}

resource "kubectl_manifest" "strimzi_operator" {
  count     = length(data.kubectl_file_documents.strimzi_operator_manifests.documents)
  yaml_body = element(data.kubectl_file_documents.strimzi_operator_manifests.documents, count.index)

  depends_on = [kubernetes_namespace.strimzi_ns]
}