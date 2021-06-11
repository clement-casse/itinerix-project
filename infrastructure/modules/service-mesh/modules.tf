module "istio" {
    count  = var.implementation == "istio" ? 1 : 0
    source = "../service-mesh-istio"

    istio_version   = var.istio_version
    istio_namespace = var.istio_namespace

    domain_name        = var.domain_name
    tracing_namespace  = var.tracing_namespace
    polynote_namespace = var.polynote_namespace

    k8s_host                   = var.k8s_host
    k8s_token                  = var.k8s_token
    k8s_cluster_ca_certificate = var.k8s_cluster_ca_certificate

    project      = var.project
    region       = var.region
    cluster_name = var.cluster_name
}

module "linkerd" {
    count  = var.implementation == "linkerd" ? 1 : 0
    source = "../service-mesh-linkerd"

    linkerd_version   = var.linkerd_version
    linkerd_namespace = var.linkerd_namespace
    dashboard_users   = var.dashboard_users

    domain_name        = var.domain_name
    tracing_namespace  = var.tracing_namespace
    polynote_namespace = var.polynote_namespace

    k8s_host                   = var.k8s_host
    k8s_token                  = var.k8s_token
    k8s_cluster_ca_certificate = var.k8s_cluster_ca_certificate

    project      = var.project
    region       = var.region
    cluster_name = var.cluster_name
}