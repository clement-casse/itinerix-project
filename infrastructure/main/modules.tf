## Cannot use client autentication returned by the Google_container_cluster provider: no permission on the cluster
## Using `google_client_config` datasource to get admin token on GKE
## Reference: https://github.com/kubernetes/kubernetes/issues/65400#issuecomment-446328168

data "google_client_config" "current" {}

module "cluster" {
    source = "../modules/cluster-google-cloud"

    project = var.gke_project
    region  = var.gke_region

    zone_pool_1  = var.gke_zone_pool_1
    zone_pool_2  = var.gke_zone_pool_2
    cluster_name = var.gke_cluster_name
}

module "service_mesh" {
    source = "../modules/service-mesh-linkerd"

    k8s_host                   = module.cluster.host
    k8s_token                  = data.google_client_config.current.access_token
    k8s_cluster_ca_certificate = module.cluster.cluster_ca_certificate
    acme_email                 = var.acme_email
    domain_name                = var.acme_domain
    dashboard_users            = var.dashboard_users
}

module "domain" {
    source = "../modules/dns-google-cloud"

    project = var.gke_project
    region  = var.gke_region

    load_balancer_ip = module.service_mesh.load_balancer_ip
    domain           = var.acme_domain
}

module "prometheus_operator" {
    source = "../modules/operator-prometheus"

    k8s_host                   = module.cluster.host
    k8s_token                  = data.google_client_config.current.access_token
    k8s_cluster_ca_certificate = module.cluster.cluster_ca_certificate
}

# REMOVING SOME MODULE WITH CRDs & HUGE LOCAL FILES AS THEY MAKE TERRAFORM STATE BE TOO LARGE
# THEREFORE ANY PLAN IN TERRAFORM FAILS
# module "strimzi_operator" {
#     source = "../modules/operator-strimzi"
# 
#     k8s_host                   = module.cluster.host
#     k8s_token                  = data.google_client_config.current.access_token
#     k8s_cluster_ca_certificate = module.cluster.cluster_ca_certificate
# }

module "stack-tracing" {
    source = "../modules/stack-tracing"

    k8s_host                   = module.cluster.host
    k8s_token                  = data.google_client_config.current.access_token
    k8s_cluster_ca_certificate = module.cluster.cluster_ca_certificate

    domain_name  = var.acme_domain
    jaeger_users = var.dashboard_users
}

module "stack-data" {
    source = "../modules/stack-data"

    k8s_host                   = module.cluster.host
    k8s_token                  = data.google_client_config.current.access_token
    k8s_cluster_ca_certificate = module.cluster.cluster_ca_certificate

    domain_name    = var.acme_domain
    notebook_users = var.dashboard_users
}
