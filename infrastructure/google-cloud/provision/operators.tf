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
  content = file("./provision/generated-manifests/strimzi-operator.yaml")
}

resource "kubectl_manifest" "strimzi_operator" {
  count     = length(data.kubectl_file_documents.strimzi_operator_manifests.documents)
  yaml_body = element(data.kubectl_file_documents.strimzi_operator_manifests.documents, count.index)

  depends_on = [kubernetes_namespace.strimzi_ns]
}

data "kubectl_file_documents" "prometheus_operator_manifests" {
  content = file("./provision/generated-manifests/prometheus-operator.yaml")
}

resource "kubectl_manifest" "prometheus_operator" {
  count     = length(data.kubectl_file_documents.prometheus_operator_manifests.documents)
  yaml_body = element(data.kubectl_file_documents.prometheus_operator_manifests.documents, count.index)

  depends_on = [kubernetes_namespace.prometheus_operator_ns]
}

data "kubectl_file_documents" "eck_operator_manifests" {
  content = file("./provision/generated-manifests/eck-operator.yaml")
}

resource "kubectl_manifest" "eck_operator" {
  count     = length(data.kubectl_file_documents.eck_operator_manifests.documents)
  yaml_body = element(data.kubectl_file_documents.eck_operator_manifests.documents, count.index)
}

data "kubectl_file_documents" "linkerd_config_manifests" {
  content = file("./provision/generated-manifests/linkerd-config.yaml")
}

resource "kubectl_manifest" "linkerd_config" {
  count     = length(data.kubectl_file_documents.linkerd_config_manifests.documents)
  yaml_body = element(data.kubectl_file_documents.linkerd_config_manifests.documents, count.index)
}

data "kubectl_file_documents" "linkerd_controlplane_manifests" {
  content = file("./provision/generated-manifests/linkerd-controlplane.yaml")
}

resource "kubectl_manifest" "linkerd_controlplane" {
  count     = length(data.kubectl_file_documents.linkerd_controlplane_manifests.documents)
  yaml_body = element(data.kubectl_file_documents.linkerd_controlplane_manifests.documents, count.index)

  depends_on = [kubectl_manifest.linkerd_config]
}
