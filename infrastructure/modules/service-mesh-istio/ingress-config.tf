locals {
  jaeger_host         = "monitoring.${var.domain_name}"
  jaeger_pathprefix   = "/jaeger"
  jaeger_namespace    = var.tracing_namespace

  notebook_host       = "grapher.${var.domain_name}"
  notebook_pathprefix = "/notebooks"
  notebook_namespace  = var.polynote_namespace

  app_host      = "app.${var.domain_name}"
  app_namespace = "app"
}

## MONITORING NAMESPACE
resource "kubectl_manifest" "monitoring_ingress_gateway" {
  yaml_body = <<-EOF
  apiVersion: networking.istio.io/v1alpha3
  kind: Gateway
  metadata:
    name: monitoring-gateway
    namespace: ${local.jaeger_namespace}
  spec:
    selector:
      istio: ingressgateway
    servers:
    - hosts: [ "${local.jaeger_host}" ]
      port:
        number: 80
        name: http
        protocol: HTTP
      tls:
        httpsRedirect: true
    - hosts: [ "${local.jaeger_host}" ]
      port:
        number: 443
        name: https
        protocol: HTTPS
      tls:
        mode: SIMPLE
        credentialName: monitoring-ingress-cert
  EOF
}

resource "kubectl_manifest" "jaeger_virtual_service" {
  yaml_body = <<-EOF
  apiVersion: networking.istio.io/v1alpha3
  kind: VirtualService
  metadata:
    name: jaeger-ingress
    namespace: ${local.jaeger_namespace}
  spec:
    hosts: [ "${local.jaeger_host}" ]
    gateways:
    - monitoring-gateway
    http:
    - name: jaeger-route
      match:
      - uri:
          prefix: "${local.jaeger_pathprefix}"
      route:
      - destination:
          host: jaeger-query.${local.jaeger_namespace}.svc.cluster.local
          port:
            number: 16686
  EOF
}


## DATA NAMESPACE
resource "kubectl_manifest" "data_ingress_gateway" {
  yaml_body = <<-EOF
  apiVersion: networking.istio.io/v1alpha3
  kind: Gateway
  metadata:
    name: data-gateway
    namespace: ${local.notebook_namespace}
  spec:
    selector:
      istio: ingressgateway
    servers:
    - hosts: [ "${local.notebook_host}" ]
      port:
        number: 80
        name: http
        protocol: HTTP
      tls:
        httpsRedirect: true
    - hosts: [ "${local.notebook_host}" ]
      port:
        number: 443
        name: https
        protocol: HTTPS
      tls:
        mode: SIMPLE
        credentialName: grapher-ingress-cert
  EOF
}

resource "kubectl_manifest" "data_notebook_virtual_service" {
  yaml_body = <<-EOF
  apiVersion: networking.istio.io/v1alpha3
  kind: VirtualService
  metadata:
    name: notebook-ingress
    namespace: ${local.notebook_namespace}
  spec:
    hosts: [ "${local.notebook_host}" ]
    gateways:
    - data-gateway
    http:
    - name: notebook-route
      match:
      - uri:
          prefix: "${local.notebook_pathprefix}/"
      rewrite:
        uri: /
      route:
      - destination:
          host: polynote.${local.notebook_namespace}.svc.cluster.local
          port:
            number: 8192
  EOF
}


resource "kubectl_manifest" "app_ingress_gateway" {
  yaml_body = <<-EOF
  apiVersion: networking.istio.io/v1alpha3
  kind: Gateway
  metadata:
    name: app-gateway
    namespace: ${local.app_namespace}
  spec:
    selector:
      istio: ingressgateway
    servers:
    - hosts: [ "${local.app_host}" ]
      port:
        number: 80
        name: http
        protocol: HTTP
      tls:
        httpsRedirect: true
    - hosts: [ "${local.app_host}" ]
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
    namespace: ${local.app_namespace}
  spec:
    hosts: [ "${local.app_host}" ]
    gateways:
    - data-gateway
    hosts:
    - "${local.app_host}"
    - "frontend.${local.app_namespace}.svc.cluster.local"
    gateways:
    - app-gateway
    http:
    - route:
      - destination:
          host: frontend.${local.app_namespace}.svc.cluster.local
          port:
            number: 80
  EOF
}
