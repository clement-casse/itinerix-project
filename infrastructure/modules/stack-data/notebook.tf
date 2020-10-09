resource "kubernetes_namespace" "data_ns" {
  metadata {
    name = "data"
    annotations = {
      "linkerd.io/inject" = "disabled"
    }
    labels = {
      istio-injection = "disabled"
    }
  }
}

data "kubectl_file_documents" "data_manifests" {
  content = file("${path.module}/generated-manifests/notebook.yaml")
}

resource "kubectl_manifest" "notebook" {
  count     = length(data.kubectl_file_documents.data_manifests.documents)
  yaml_body = element(data.kubectl_file_documents.data_manifests.documents, count.index)

  depends_on = [kubernetes_namespace.data_ns]
}


resource "kubernetes_secret" "notebook_auth" {
  metadata {
    name      = "notebook-basic-auth"
    namespace = kubernetes_namespace.data_ns.metadata.0.name
  }

  data = {
    users = var.notebook_users
  }
}


###
### LINKERD + TRAEFIK SPECIFIC FOR INGRESS TRAFFIC
###

resource "kubectl_manifest" "notebook_ingress_cfg" {
  yaml_body = <<-EOF
  ---
  apiVersion: traefik.containo.us/v1alpha1
  kind: Middleware
  metadata:
    name: notebook-auth
    namespace: ${kubernetes_namespace.data_ns.metadata.0.name}
  spec:
    basicAuth:
      secret: ${kubernetes_secret.notebook_auth.metadata.0.name}
  ---
  apiVersion: traefik.containo.us/v1alpha1
  kind: Middleware
  metadata:
    name: polynote-strip-prefix
    namespace: ${kubernetes_namespace.data_ns.metadata.0.name}
  spec:
    stripPrefix:
      prefixes:
      - "/notebooks"
      forceSlash: true
  ---
  apiVersion: traefik.containo.us/v1alpha1
  kind: IngressRoute
  metadata:
    name: notebook
    namespace: ${kubernetes_namespace.data_ns.metadata.0.name}
  spec:
    entryPoints:
    - http
    - https
    routes:
    - kind: Rule
      match: Host(`grapher.${var.domain_name}`) && PathPrefix(`/notebooks/`)
      services:
      - name: polynote
        kind: Service
        port: 8192
      middlewares:
      - name: notebook-auth
      - name: polynote-strip-prefix
    tls:
      certResolver: default
  ---
  apiVersion: traefik.containo.us/v1alpha1
  kind: IngressRoute
  metadata:
    name: neo4j-bolt
    namespace: ${kubernetes_namespace.data_ns.metadata.0.name}
  spec:
    entryPoints:
    - http-bolt
    routes:
    - kind: Rule
      match: Host(`*`)
      services:
      - name: neo4j
        port: 7687
      middlewares: []
  ---
  apiVersion: traefik.containo.us/v1alpha1
  kind: IngressRoute
  metadata:
    name: neo4j-http
    namespace: ${kubernetes_namespace.data_ns.metadata.0.name}
  spec:
    entryPoints:
    - http
    - https
    routes:
    - kind: Rule
      match: >-
        Host(`*`) && (
        PathPrefix(`/browser/`) || (
        PathPrefix(`/db/`) && Headers(`Content-Type`, `application/json`) && Headers(`Accept`, `application/json`)
        )
        )
      services:
      - name: neo4j
        port: 7474
      middlewares: []
  EOF
}
