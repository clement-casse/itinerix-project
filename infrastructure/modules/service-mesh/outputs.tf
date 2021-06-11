output "load_balancer_ip" {
  value = coalesce(
    one(module.istio[*].load_balancer_ip),
    one(module.linkerd[*].load_balancer_ip)
  )
}

output "namespace" {
  value = coalesce(
    one(module.istio[*].namespace),
    one(module.linkerd[*].namespace)
  )
}

output "certificate_target_namespace" {
  value = coalesce(
    one(module.istio[*].certificate_target_namespace),
    one(module.linkerd[*].certificate_target_namespace)
  )
}