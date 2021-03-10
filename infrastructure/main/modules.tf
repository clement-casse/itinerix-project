## Cannot use client autentication returned by the Google_container_cluster provider: no permission on the cluster
## Using `google_client_config` datasource to get admin token on GKE
## Reference: https://github.com/kubernetes/kubernetes/issues/65400#issuecomment-446328168

data "google_client_config" "current" {}

module "cluster" {
    source = "../modules/cluster-google-cloud"

    project = var.gke_project
    region  = var.gke_region

    zone_pool_1     = var.gke_zone_pool_1
    nodes_in_pool_1 = 2
    zone_pool_2     = var.gke_zone_pool_2
    nodes_in_pool_2 = 2
    cluster_name    = var.gke_cluster_name
}

module "service_mesh" {
    source = "../modules/service-mesh-istio"

    k8s_host                   = module.cluster.host
    k8s_token                  = data.google_client_config.current.access_token
    k8s_cluster_ca_certificate = module.cluster.cluster_ca_certificate

    project      = var.gke_project
    region       = var.gke_region
    cluster_name = var.gke_cluster_name

    istio_version   = "1.9.0"
    istio_namespace = "istio-system"
    # dashboard_users            = var.dashboard_users
}

module "domain" {
    source = "../modules/dns-google-cloud"

    project = var.gke_project
    region  = var.gke_region

    load_balancer_ip = module.service_mesh.load_balancer_ip
    domain           = var.acme_domain
}

module "cert_manager" {
    source = "../modules/cert-manager"

    project      = var.gke_project
    region       = var.gke_region
    cluster_name = var.gke_cluster_name

    k8s_host                   = module.cluster.host
    k8s_token                  = data.google_client_config.current.access_token
    k8s_cluster_ca_certificate = module.cluster.cluster_ca_certificate

    certmanager_version = "v1.2.0"
    acme_email          = var.acme_email
    domain_name         = var.acme_domain

    certificates_target_ns = module.service_mesh.namespace
    certificates_to_create = module.domain.dns_records
}

module "stack_tracing" {
    source = "../modules/stack-tracing"

    project      = var.gke_project
    region       = var.gke_region
    cluster_name = var.gke_cluster_name

    k8s_host                   = module.cluster.host
    k8s_token                  = data.google_client_config.current.access_token
    k8s_cluster_ca_certificate = module.cluster.cluster_ca_certificate

    jaeger_install_ns = module.service_mesh.namespace
    jaeger_host       = "monitoring.${var.acme_domain}"
    jaeger_pathprefix = "/jaeger"
    jaeger_users      = var.dashboard_users
}

# module "prometheus_operator" {
#     source = "../modules/operator-prometheus"
#
#     k8s_host                   = module.cluster.host
#     k8s_token                  = data.google_client_config.current.access_token
#     k8s_cluster_ca_certificate = module.cluster.cluster_ca_certificate
# }

# REMOVING SOME MODULE WITH CRDs & HUGE LOCAL FILES AS THEY MAKE TERRAFORM STATE BE TOO LARGE
# THEREFORE ANY PLAN IN TERRAFORM FAILS
# module "strimzi_operator" {
#     source = "../modules/operator-strimzi"
# 
#     k8s_host                   = module.cluster.host
#     k8s_token                  = data.google_client_config.current.access_token
#     k8s_cluster_ca_certificate = module.cluster.cluster_ca_certificate
# }

# module "stack-data" {
#     source = "../modules/stack-data"
# 
#     k8s_host                   = module.cluster.host
#     k8s_token                  = data.google_client_config.current.access_token
#     k8s_cluster_ca_certificate = module.cluster.cluster_ca_certificate
# 
#     domain_name    = var.acme_domain
#     notebook_users = var.dashboard_users
# }

module "prepare_stack_app" {
    source = "../modules/prepare-stack-app"

    k8s_host                   = module.cluster.host
    k8s_token                  = data.google_client_config.current.access_token
    k8s_cluster_ca_certificate = module.cluster.cluster_ca_certificate

    domain_name = var.acme_domain
}
