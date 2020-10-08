resource "kubernetes_namespace" "linkerd_ns" {
  metadata {
    name = "linkerd"
    annotations = {
      "linkerd.io/inject" = "disabled"
    }

    labels = {
      istio-injection = "disabled"

      "config.linkerd.io/admission-webhooks" = "disabled"
      "linkerd.io/control-plane-ns"          = "linkerd"
      "linkerd.io/is-control-plane"          = "true"
    }
  }
}


data "kubectl_file_documents" "linkerd_config_manifests" {
  content = file("${path.module}/generated-manifests/linkerd-config.yaml")
}

data "kubectl_file_documents" "linkerd_controlplane_manifests" {
  content = file("${path.module}/generated-manifests/linkerd-controlplane.yaml")
}


resource "kubectl_manifest" "linkerd_config" {
  count     = length(data.kubectl_file_documents.linkerd_config_manifests.documents)
  yaml_body = element(data.kubectl_file_documents.linkerd_config_manifests.documents, count.index)

  depends_on = [kubernetes_namespace.linkerd_ns]
}

resource "kubectl_manifest" "linkerd_controlplane" {
  count     = length(data.kubectl_file_documents.linkerd_controlplane_manifests.documents)
  yaml_body = element(data.kubectl_file_documents.linkerd_controlplane_manifests.documents, count.index)

  depends_on = [kubectl_manifest.linkerd_config]
}
