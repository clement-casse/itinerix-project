output "load_balancer_ip" {
  value = kubernetes_service.traefik_lb.load_balancer_ingress.0.ip
}