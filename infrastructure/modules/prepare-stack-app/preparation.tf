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
