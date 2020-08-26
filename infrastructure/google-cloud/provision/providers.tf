## Cannot use client autentication returned by the Google_container_cluster provider: no permission on the cluster
## Using `google_client_config` datasource to get admin token on GKE
## Reference: https://github.com/kubernetes/kubernetes/issues/65400#issuecomment-446328168

data "google_client_config" "current" {}

provider "kubernetes" {
  host                   = var.host
  token                  = data.google_client_config.current.access_token
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)

  load_config_file = false
}

provider "kubectl" {
  host                   = var.host
  token                  = data.google_client_config.current.access_token
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)

  load_config_file = false
}