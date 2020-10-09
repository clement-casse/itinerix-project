resource "kubernetes_namespace" "monitoring_ns" {
  metadata {
    name = "monitoring"
    annotations = {
      "linkerd.io/inject" = "disabled"
    }
    labels = {
      istio-injection = "disabled"
    }
  }
}

data "kubectl_file_documents" "jaeger_manifests" {
  content = file("${path.module}/generated-manifests/jaeger.yaml")
}

resource "kubectl_manifest" "jaeger" {
  count     = length(data.kubectl_file_documents.jaeger_manifests.documents)
  yaml_body = element(data.kubectl_file_documents.jaeger_manifests.documents, count.index)

  depends_on = [kubernetes_namespace.monitoring_ns]
}


resource "kubernetes_secret" "jaeger_auth" {
  metadata {
    name      = "jaeger-basic-auth"
    namespace = kubernetes_namespace.monitoring_ns.metadata.0.name
  }

  data = {
    users = var.jaeger_users
  }
}


###
### LINKERD + TRAEFIK SPECIFIC FOR INGRESS TRAFFIC
###

resource "kubectl_manifest" "jaeger_ingress_cfg" {
  yaml_body = <<-EOF
  ---
  apiVersion: traefik.containo.us/v1alpha1
  kind: Middleware
  metadata:
    name: jaeger-auth
    namespace: ${kubernetes_namespace.monitoring_ns.metadata.0.name}
  spec:
    basicAuth:
      secret: ${kubernetes_secret.jaeger_auth.metadata.0.name}
  
  ---
  apiVersion: traefik.containo.us/v1alpha1
  kind: IngressRoute
  metadata:
    name: jaeger-query
    namespace: ${kubernetes_namespace.monitoring_ns.metadata.0.name}
  spec:
    entryPoints:
    - http
    - https
    routes:
    - kind: Rule
      match: Host(`monitoring.${var.domain_name}`) && PathPrefix(`/jaeger/`)
      services:
      - name: jaeger-query
        kind: Service
        port: 16686
      middlewares:
      - name: jaeger-auth
    tls:
      certResolver: default
  EOF
}
