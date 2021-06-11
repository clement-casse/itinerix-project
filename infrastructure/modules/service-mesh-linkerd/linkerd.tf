resource "null_resource" "linkerd_service_mesh_clusterwide" {
  triggers = {
    linkerd_version = var.linkerd_version
  }

  provisioner "local-exec" {
    command     = "gcloud container clusters get-credentials $CLUSTER_NAME --region $REGION"
    environment = {
      CLUSTER_NAME = var.cluster_name
      REGION       = var.region
    }
  }

  provisioner "local-exec" {
    command     = "make install-linkerd-clusterwide-config KUBECONTEXT=$CONTEXT LINKERD2_VERSION=$LINKERD_VERSION LINKERD2_NS=$LINKERD_NAMESPACE"
    working_dir = path.module

    environment = {
      LINKERD_VERSION   = var.linkerd_version
      LINKERD_NAMESPACE = var.linkerd_namespace
      CONTEXT           = "gke_${var.project}_${var.region}_${var.cluster_name}"
    }
  }

  # provisioner "local-exec" {
  #   when        = destroy
  #   command     = "make remove-linkerd-clusterwide-config KUBECONTEXT=$CONTEXT LINKERD2_VERSION=$LINKERD_VERSION LINKERD2_NS=$LINKERD_NAMESPACE"
  #   working_dir = path.module

  #   environment = {
  #     LINKERD_VERSION   = var.linkerd_version
  #     LINKERD_NAMESPACE = var.linkerd_namespace
  #     CONTEXT           = "gke_${var.project}_${var.region}_${var.cluster_name}"
  #   }
  # }
}


resource "null_resource" "linkerd_service_mesh" {
  triggers = {
    linkerd_version = var.linkerd_version
  }

  depends_on = [ null_resource.linkerd_service_mesh_clusterwide ]

  provisioner "local-exec" {
    command     = "gcloud container clusters get-credentials $CLUSTER_NAME --region $REGION"
    environment = {
      CLUSTER_NAME = var.cluster_name
      REGION       = var.region
    }
  }

  provisioner "local-exec" {
    command     = "make install-linkerd KUBECONTEXT=$CONTEXT LINKERD2_VERSION=$LINKERD_VERSION LINKERD2_NS=$LINKERD_NAMESPACE"
    working_dir = path.module

    environment = {
      LINKERD_VERSION   = var.linkerd_version
      LINKERD_NAMESPACE = var.linkerd_namespace
      CONTEXT           = "gke_${var.project}_${var.region}_${var.cluster_name}"
    }
  }

  # provisioner "local-exec" {
  #   when        = destroy
  #   command     = "make remove-linkerd KUBECONTEXT=$CONTEXT LINKERD2_VERSION=$LINKERD_VERSION LINKERD2_NS=$LINKERD_NAMESPACE"
  #   working_dir = path.module

  #   environment = {
  #     LINKERD_VERSION   = var.linkerd_version
  #     LINKERD_NAMESPACE = var.linkerd_namespace
  #     CONTEXT           = "gke_${var.project}_${var.region}_${var.cluster_name}"
  #   }
  # }
}


data "kubernetes_namespace" "linkerd_ns" {
  metadata {
    name = var.linkerd_namespace
  }

  depends_on = [ null_resource.linkerd_service_mesh ]
}
