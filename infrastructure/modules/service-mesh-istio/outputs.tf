output "load_balancer_ip" {
  value = data.kubernetes_service.istio_ingressgateway.status.0.load_balancer.0.ingress.0.ip
}

output "namespace" {
  value = data.kubernetes_service.istio_ingressgateway.metadata.0.namespace
}

output "certificate_target_namespace" {
  value = data.kubernetes_service.istio_ingressgateway.metadata.0.namespace
}