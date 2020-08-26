resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  project  = var.project
  location = var.region

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  master_auth {
    # diable basic auth by providing empty user / password
    username = ""
    password = ""
  }
}

resource "google_container_node_pool" "node-pool-1" {
  cluster    = google_container_cluster.primary.name
  location   = var.region
  name       = "pool-1"
  node_count = 1

  node_locations = [
    var.zone_pool_1,
  ]

  node_config {
    preemptible  = true
    machine_type = "e2-medium"
    disk_size_gb = 30

    labels = {
      cluster = var.cluster_name
      zone    = var.zone_pool_1
    }

    metadata = {
      disable-legacy-endpoints = true
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append",
    ]
  }
}

resource "google_container_node_pool" "node-pool-2" {
  cluster    = google_container_cluster.primary.name
  location   = var.region
  name       = "pool-2"
  node_count = 2

  node_locations = [
    var.zone_pool_2,
  ]

  node_config {
    preemptible  = true
    machine_type = "e2-medium"
    disk_size_gb = 30

    metadata = {
      disable-legacy-endpoints = true
    }

    labels = {
      cluster = var.cluster_name
      zone    = var.zone_pool_2
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append",
    ]
  }
}
