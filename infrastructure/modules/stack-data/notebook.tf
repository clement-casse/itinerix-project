resource "kubernetes_namespace" "data_ns" {
  metadata {
    name = var.notebook_install_ns
    annotations = {
      "linkerd.io/inject" = "disabled"
    }
    labels = {
      istio-injection = "disabled"
    }
  }
}

resource "null_resource" "polynote_neo4j_kustomization" {
  provisioner "local-exec" {
    command     = <<-SCRIPT
      kustomize build ./kustomization \
      | kubectl apply --namespace=$DATA_NAMESPACE --context=$CONTEXT --filename -
    SCRIPT
    working_dir = path.module

    environment = {
      DATA_NAMESPACE = kubernetes_namespace.data_ns.metadata.0.name
      CONTEXT        = "gke_${var.project}_${var.region}_${var.cluster_name}"
    }
  }
}

data "kubernetes_service" "polynote_endpoint" {
  metadata {
    name      = "polynote"
    namespace = kubernetes_namespace.data_ns.metadata.0.name
  }

  depends_on = [ null_resource.polynote_neo4j_kustomization ]
}
