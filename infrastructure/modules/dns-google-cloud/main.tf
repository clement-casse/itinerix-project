
resource "google_dns_managed_zone" "main_zone" {
  name        = "main-zone"
  dns_name    = "${var.domain}."
  description = "Main DNS zone for itinerix project"
}

resource "google_dns_record_set" "app_endpoint" {
  name = "app.${google_dns_managed_zone.main_zone.dns_name}"
  type = "A"
  ttl  = 300
  
  managed_zone = google_dns_managed_zone.main_zone.name

  rrdatas = [ var.load_balancer_ip ]
}

resource "google_dns_record_set" "monitoring_endpoint" {
  name = "monitoring.${google_dns_managed_zone.main_zone.dns_name}"
  type = "A"
  ttl  = 300
  
  managed_zone = google_dns_managed_zone.main_zone.name

  rrdatas = [ var.load_balancer_ip ]
}

resource "google_dns_record_set" "grapher_endpoint" {
  name = "grapher.${google_dns_managed_zone.main_zone.dns_name}"
  type = "A"
  ttl  = 300
  
  managed_zone = google_dns_managed_zone.main_zone.name

  rrdatas = [ var.load_balancer_ip ]
}
