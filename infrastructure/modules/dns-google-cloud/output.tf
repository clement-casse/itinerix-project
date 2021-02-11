output "dns_records" {
  value = [
    trimsuffix(google_dns_record_set.app_endpoint.name, "."),
    trimsuffix(google_dns_record_set.monitoring_endpoint.name, "."),
    trimsuffix(google_dns_record_set.grapher_endpoint.name, "."),
  ]
}