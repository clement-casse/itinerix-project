resource "null_resource" "istio_service_mesh" {
  triggers = {
    istio_version           = var.istio_version
    istio_operator_manifest = filesha1("${path.module}/k8s-manifests/istio-operator.yaml")
  }

  provisioner "local-exec" {
    command     = "gcloud container clusters get-credentials $CLUSTER_NAME --region $REGION"

    environment = {
      CLUSTER_NAME = var.cluster_name
      REGION       = var.region
    }
  }

  provisioner "local-exec" {
    command     = "make install-istio KUBECONTEXT=$CONTEXT ISTIO_VERSION=$ISTIO_VERSION ISTIO_NAMESPACE=$ISTIO_NAMESPACE"
    working_dir = path.module

    environment = {
      ISTIO_VERSION   = var.istio_version
      ISTIO_NAMESPACE = var.istio_namespace
      CONTEXT         = "gke_${var.project}_${var.region}_${var.cluster_name}"
    }
  }
}

data "kubernetes_namespace" "istio_ns" {
  metadata {
    name = var.istio_namespace
  }

  depends_on = [ null_resource.istio_service_mesh ]
}

data "kubernetes_service" "istio_ingressgateway" {
  metadata {
    name      = "istio-ingressgateway"
    namespace = var.istio_namespace
  }

  depends_on = [ null_resource.istio_service_mesh ]
}