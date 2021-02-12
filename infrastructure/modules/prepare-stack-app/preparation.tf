resource "kubernetes_namespace" "app_ns" {
  metadata {
    name = "app"
    annotations = {
      "linkerd.io/inject" = "enabled"
    }
    labels = {
      istio-injection = "enabled"
    }
  }
}

###
### ISTIO SPECIFIC FOR INGRESS TRAFFIC
###

resource "kubectl_manifest" "data_ingress_gateway" {
  yaml_body = <<-EOF
  apiVersion: networking.istio.io/v1alpha3
  kind: Gateway
  metadata:
    name: app-gateway
    namespace: ${kubernetes_namespace.app_ns.metadata.0.name}
  spec:
    selector:
      istio: ingressgateway
    servers:
    - hosts: [ "app.${var.domain_name}" ]
      port:
        number: 80
        name: http
        protocol: HTTP
      tls:
        httpsRedirect: true
    - hosts: [ "app.${var.domain_name}" ]
      port:
        number: 443
        name: https
        protocol: HTTPS
      tls:
        mode: SIMPLE
        credentialName: app-ingress-cert
  EOF
}

resource "kubectl_manifest" "app_frontend_vs" {
  yaml_body = <<-EOF
  apiVersion: networking.istio.io/v1alpha3
  kind: VirtualService
  metadata:
    name: app-ingress
    namespace: ${kubernetes_namespace.app_ns.metadata.0.name}
  spec:
    hosts: [ "app.${var.domain_name}" ]
    gateways:
    - data-gateway
    hosts:
    - "app.${var.domain_name}"
    - "frontend.${kubernetes_namespace.app_ns.metadata.0.name}.svc.cluster.local"
    gateways:
    - app-gateway
    http:
    - route:
      - destination:
          host: frontend.${kubernetes_namespace.app_ns.metadata.0.name}.svc.cluster.local
          port:
            number: 80
  EOF
}
