resource "kubernetes_namespace" "traefik_ns" {
  metadata {
    name = "traefik"
    annotations = {
      "linkerd.io/inject" = "disabled"
    }
    labels = {
      istio-injection = "disabled"
    }
  }
}

resource "kubernetes_service" "traefik_lb" {
  metadata {
    name      = "traefik"
    namespace = kubernetes_namespace.traefik_ns.metadata.0.name
  }
  spec {
    type = "LoadBalancer"
    selector = {
      "component" = "traefik"
    }
    port {
      name        = "http"
      port        = 80
      target_port = "http"
    }
    port {
      name        = "https"
      port        = 443
      target_port = "https"
    }
    port {
      name        = "http-bolt"
      port        = 7687
      target_port = "http-bolt"
    }
  }
}


resource "kubectl_manifest" "traefik_crds" {
  yaml_body = <<-YAML
  # All resources definition must be declared
  apiVersion: apiextensions.k8s.io/v1beta1
  kind: CustomResourceDefinition
  metadata:
    name: ingressroutes.traefik.containo.us

  spec:
    version: v1alpha1
    group: traefik.containo.us
    scope: Namespaced
    names:
      kind: IngressRoute
      plural: ingressroutes
      singular: ingressroute

  ---
  apiVersion: apiextensions.k8s.io/v1beta1
  kind: CustomResourceDefinition
  metadata:
    name: middlewares.traefik.containo.us

  spec:
    version: v1alpha1
    group: traefik.containo.us
    scope: Namespaced
    names:
      kind: Middleware
      plural: middlewares
      singular: middleware

  ---
  apiVersion: apiextensions.k8s.io/v1beta1
  kind: CustomResourceDefinition
  metadata:
    name: ingressroutetcps.traefik.containo.us

  spec:
    version: v1alpha1
    group: traefik.containo.us
    scope: Namespaced
    names:
      kind: IngressRouteTCP
      plural: ingressroutetcps
      singular: ingressroutetcp

  ---
  apiVersion: apiextensions.k8s.io/v1beta1
  kind: CustomResourceDefinition
  metadata:
    name: ingressrouteudps.traefik.containo.us

  spec:
    version: v1alpha1
    group: traefik.containo.us
    scope: Namespaced
    names:
      kind: IngressRouteUDP
      plural: ingressrouteudps
      singular: ingressrouteudp

  ---
  apiVersion: apiextensions.k8s.io/v1beta1
  kind: CustomResourceDefinition
  metadata:
    name: tlsoptions.traefik.containo.us

  spec:
    version: v1alpha1
    group: traefik.containo.us
    scope: Namespaced
    names:
      kind: TLSOption
      plural: tlsoptions
      singular: tlsoption

  ---
  apiVersion: apiextensions.k8s.io/v1beta1
  kind: CustomResourceDefinition
  metadata:
    name: tlsstores.traefik.containo.us

  spec:
    version: v1alpha1
    group: traefik.containo.us
    scope: Namespaced
    names:
      kind: TLSStore
      plural: tlsstores
      singular: tlsstore

  ---
  apiVersion: apiextensions.k8s.io/v1beta1
  kind: CustomResourceDefinition
  metadata:
    name: traefikservices.traefik.containo.us

  spec:
    version: v1alpha1
    group: traefik.containo.us
    scope: Namespaced
    names:
      kind: TraefikService
      plural: traefikservices
      singular: traefikservice
  YAML
}
