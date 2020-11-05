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
### LINKERD + TRAEFIK SPECIFIC FOR INGRESS TRAFFIC
###

resource "kubectl_manifest" "app_ingress_cfg" {
  yaml_body = <<-EOF
  ---
  apiVersion: traefik.containo.us/v1alpha1
  kind: Middleware
  metadata:
    name: l5d-header-middleware
    namespace: ${kubernetes_namespace.app_ns.metadata.0.name}
  spec:
    headers:
      customRequestHeaders:
        l5d-dst-override: "frontend.app.svc.cluster.local:80"
  ---
  apiVersion: traefik.containo.us/v1alpha1
  kind: IngressRoute
  metadata:
    name: microserives-demo-frontend
    namespace: ${kubernetes_namespace.app_ns.metadata.0.name}
  spec:
    entryPoints:
    - http
    - https
    routes:
    - kind: Rule
      match: Host(`app.${var.domain_name}`)
      services:
      - name: frontend
        kind: Service
        port: 80
      middlewares:
      - name: l5d-header-middleware
    tls:
      certResolver: default
  EOF
}

###
### ISTIO SPECIFIC FOR INGRESS TRAFFIC
###

# resource "kubectl_manifest" "app_ingress_cfg" {
#   yaml_body = <<-EOF
#   ---
#   apiVersion: networking.istio.io/v1alpha3
#   kind: Gateway
#   metadata:
#     name: frontend-gateway
#     namespace: ${kubernetes_namespace.app_ns.metadata.0.name}
#   spec:
#     selector:
#       istio: ingressgateway
#     servers:
#     - hosts: [ "app.${var.domain_name}" ]
#       port:
#         number: 80
#         name: http
#         protocol: HTTP
#   ---
#   apiVersion: networking.istio.io/v1alpha3
#   kind: VirtualService
#   metadata:
#     name: frontend-ingress
#     namespace: ${kubernetes_namespace.app_ns.metadata.0.name}
#   spec:
#     hosts:
#     - "app.${var.domain_name}"
#     - "frontend.${kubernetes_namespace.app_ns.metadata.0.name}.svc.cluster.local"
#     gateways:
#     - frontend-gateway
#     http:
#     - route:
#       - destination:
#           host: frontend
#           port:
#             number: 80
#   ---
#   apiVersion: networking.istio.io/v1alpha3
#   kind: ServiceEntry
#   metadata:
#     name: whitelist-egress-googleapis
#     namespace: ${kubernetes_namespace.app_ns.metadata.0.name}
#   spec:
#     hosts:
#     - "accounts.google.com"
#     - "*.googleapis.com"
#     ports:
#     - number: 80
#       protocol: HTTP
#       name: http
#     - number: 443
#       protocol: HTTPS
#       name: https
#   ---
#   apiVersion: networking.istio.io/v1alpha3
#   kind: ServiceEntry
#   metadata:
#     name: whitelist-egress-google-metadata
#     namespace: ${kubernetes_namespace.app_ns.metadata.0.name}
#   spec:
#     hosts:
#     - metadata.google.internal
#     addresses:
#     - 169.254.169.254
#     ports:
#     - number: 80
#       name: http
#       protocol: HTTP
#     - number: 443
#       name: https
#       protocol: HTTPS
#   EOF
# }
