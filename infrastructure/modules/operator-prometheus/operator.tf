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

data "kubectl_filename_list" "prometheus_operator_crds_manifests" {
  pattern = "${path.module}/kustomization/installation-manifests/monitoring.coreos.com_*.yaml"
}

resource "kubectl_manifest" "prometheus_operator_crds" {
  count     = length(data.kubectl_filename_list.prometheus_operator_crds_manifests.matches)
  yaml_body = file(element(data.kubectl_filename_list.prometheus_operator_crds_manifests.matches, count.index))
}


data "kubectl_file_documents" "prometheus_operator_manifests" {
  content = file("${path.module}/kustomization/generated-manifest.yaml")
}

resource "kubectl_manifest" "prometheus_operator" {
  count     = length(data.kubectl_file_documents.prometheus_operator_manifests.documents)
  yaml_body = element(data.kubectl_file_documents.prometheus_operator_manifests.documents, count.index)

  depends_on = [
    kubernetes_namespace.prometheus_operator_ns,
    kubectl_manifest.prometheus_operator_crds
  ]
}
