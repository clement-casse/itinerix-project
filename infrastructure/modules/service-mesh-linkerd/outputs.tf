output "load_balancer_ip" {
  value = kubernetes_service.traefik_lb.status.0.load_balancer.0.ingress.0.ip
}

output "namespace" {
  value = data.kubernetes_namespace.linkerd_ns.metadata.0.name
}

output "certificate_target_namespace" {
  value = kubernetes_service.traefik_lb.metadata.0.name
}