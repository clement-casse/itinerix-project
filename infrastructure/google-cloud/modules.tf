module "cluster" {
    source = "./cluster"

    project = var.gke_project
    region  = var.gke_region

    zone_pool_1  = var.gke_zone_pool_1
    zone_pool_2  = var.gke_zone_pool_2
    cluster_name = var.gke_cluster_name
}

module "provision" {
    source = "./provision"

    host                   = module.cluster.host
    cluster_ca_certificate = module.cluster.cluster_ca_certificate
}

module "domain" {
    source = "./domain"

    project = var.gke_project
    region  = var.gke_region

    load_balancer_ip = module.provision.load_balancer_ip
    domain           = var.domain_name
}
