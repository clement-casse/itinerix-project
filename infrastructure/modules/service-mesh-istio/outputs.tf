output "load_balancer_ip" {
  value = kubernetes_service.istio_ingressgateway.load_balancer_ingress.0.ip
}