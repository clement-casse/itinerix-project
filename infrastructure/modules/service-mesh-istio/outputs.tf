data "kubernetes_service" "ingressgateway" {
  metadata {
    name      = "istio-ingressgateway"
    namespace = "istio-system"
  }
}

output "load_balancer_ip" {
  value = data.kubernetes_service.ingressgateway.load_balancer_ingress.0.ip
}