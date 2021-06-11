locals {
  jaeger_host         = "monitoring.${var.domain_name}"
  jaeger_pathprefix   = "/jaeger"
  jaeger_namespace    = var.tracing_namespace
  notebook_host       = "grapher.${var.domain_name}"
  notebook_pathprefix = "/notebooks"
  notebook_namespace  = var.polynote_namespace
}

resource "kubernetes_secret" "traefik_auth" {
  metadata {
    name      = "traefik-basic-auth"
    namespace = kubernetes_namespace.traefik_ns.metadata.0.name
  }

  data = {
    users = var.dashboard_users
  }
}

resource "kubectl_manifest" "traefik_basicauth_middleware" {
  yaml_body = <<-EOF
  apiVersion: traefik.containo.us/v1alpha1
  kind: Middleware
  metadata:
    name: traefik-auth
    namespace: ${kubernetes_namespace.traefik_ns.metadata.0.name}
  spec:
    basicAuth:
      secret: ${kubernetes_secret.traefik_auth.metadata.0.name}
  EOF

  depends_on = [ kubectl_manifest.traefik_crds, kubectl_manifest.traefik_rbac ]
}

resource "kubectl_manifest" "traefik_stripprefixpolynote_middleware" {
  yaml_body = <<-EOF
  apiVersion: traefik.containo.us/v1alpha1
  kind: Middleware
  metadata:
    name: polynote-strip-prefix
    namespace: ${kubernetes_namespace.traefik_ns.metadata.0.name}
  spec:
    stripPrefix:
      prefixes:
      - "${local.notebook_pathprefix}"
      forceSlash: true
  EOF

  depends_on = [ kubectl_manifest.traefik_crds, kubectl_manifest.traefik_rbac ]
}

resource "kubectl_manifest" "traefik_dashboard_ingressroute" {
  yaml_body = <<-EOF
  apiVersion: traefik.containo.us/v1alpha1
  kind: IngressRoute
  metadata:
    name: traefik-dashboard
    namespace: ${kubernetes_namespace.traefik_ns.metadata.0.name}
  spec:
    entryPoints:
    - http
    - https
    tls:
      secretName: monitoring-ingress-cert
    routes:
    - kind: Rule
      match: Host(`${local.jaeger_host}`) && (PathPrefix(`/api`) || PathPrefix(`/dashboard`))
      middlewares:
      - name: traefik-auth
        namespace: ${kubernetes_namespace.traefik_ns.metadata.0.name}
      services:
      - kind: TraefikService
        name: api@internal
  EOF

  depends_on = [ kubectl_manifest.traefik_crds, kubectl_manifest.traefik_rbac ]
}

resource "kubectl_manifest" "jaeger_query_ingressroute" {
  yaml_body = <<-EOF
  apiVersion: traefik.containo.us/v1alpha1
  kind: IngressRoute
  metadata:
    name: jaeger-query
    namespace: ${kubernetes_namespace.traefik_ns.metadata.0.name}
  spec:
    entryPoints:
    - http
    - https
    tls:
      secretName: monitoring-ingress-cert
    routes:
    - kind: Rule
      match: Host(`${local.jaeger_host}`) && PathPrefix(`${local.jaeger_pathprefix}/`)
      middlewares:
      - name: traefik-auth
        namespace: ${kubernetes_namespace.traefik_ns.metadata.0.name}
      services:
      - kind: Service
        name: jaeger-query
        namespace: ${local.jaeger_namespace}
        port: 16686
  EOF

  depends_on = [ kubectl_manifest.traefik_crds, kubectl_manifest.traefik_rbac ]
}

resource "kubectl_manifest" "notebook_ingress_cfg" {
  yaml_body = <<-EOF
  apiVersion: traefik.containo.us/v1alpha1
  kind: IngressRoute
  metadata:
    name: notebook
    namespace: ${kubernetes_namespace.traefik_ns.metadata.0.name}
  spec:
    entryPoints:
    - http
    - https
    tls:
      secretName: grapher-ingress-cert
    routes:
    - kind: Rule
      match: Host(`${local.notebook_host}`) && PathPrefix(`${local.notebook_pathprefix}/`)
      middlewares:
      - name: traefik-auth
        namespace: ${kubernetes_namespace.traefik_ns.metadata.0.name}
      - name: polynote-strip-prefix
        namespace: ${kubernetes_namespace.traefik_ns.metadata.0.name}
      services:
      - kind: Service
        name: polynote
        namespace: ${local.notebook_namespace}
        port: 8192
  EOF

  depends_on = [ kubectl_manifest.traefik_crds, kubectl_manifest.traefik_rbac ]
}
