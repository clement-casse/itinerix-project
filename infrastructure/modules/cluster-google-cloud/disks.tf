resource "google_compute_disk" "polynote_disk" {
  name  = "polynote-data"
  type  = "pd-standard"
  zone  = var.zone_pool_2
  size  = 10

  physical_block_size_bytes = 4096
}

resource "google_compute_disk" "gremlin_disk" {
  name  = "gremlinserver-neo4j-data"
  type  = "pd-ssd"
  zone  = var.zone_pool_2
  size  = 10

  physical_block_size_bytes = 4096
}
