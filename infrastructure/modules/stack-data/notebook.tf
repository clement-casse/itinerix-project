resource "kubernetes_namespace" "data_ns" {
  metadata {
    name = var.notebook_install_ns
    annotations = {
      "linkerd.io/inject" = "disabled"
    }
    labels = {
      istio-injection = "disabled"
    }
  }
}

resource "null_resource" "polynote_neo4j_kustomization" {
  provisioner "local-exec" {
    command     = <<-SCRIPT
      kustomize build ./kustomization \
      | kubectl apply --namespace=$JAEGER_NAMESPACE --context=$CONTEXT --filename -
    SCRIPT
    working_dir = path.module

    environment = {
      DATA_NAMESPACE = kubernetes_namespace.data_ns.metadata.0.name
      CONTEXT        = "gke_${var.project}_${var.region}_${var.cluster_name}"
    }
  }
}

data "kubernetes_service" "polynote_endpoint" {
  metadata {
    name      = "polynote"
    namespace = kubernetes_namespace.data_ns.metadata.0.name
  }

  depends_on = [ null_resource.polynote_neo4j_kustomization ]
}


###
### ISTIO SPECIFIC FOR INGRESS TRAFFIC
###
resource "kubectl_manifest" "data_ingress_gateway" {
  yaml_body = <<-EOF
  apiVersion: networking.istio.io/v1alpha3
  kind: Gateway
  metadata:
    name: data-gateway
    namespace: ${kubernetes_namespace.data_ns.metadata.0.name}
  spec:
    selector:
      istio: ingressgateway
    servers:
    - hosts: [ "${var.notebook_host}" ]
      port:
        number: 80
        name: http
        protocol: HTTP
      tls:
        httpsRedirect: true
    - hosts: [ "${var.notebook_host}" ]
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
    name: polynote-ingress
    namespace: ${kubernetes_namespace.data_ns.metadata.0.name}
  spec:
    hosts: [ "${var.notebook_host}" ]
    gateways:
    - data-gateway
    http:
    - name: polynote-route
      match:
      - uri:
          prefix: "${var.notebook_pathprefix}"
      rewrite:
        uri: /
      route:
      - destination:
          host: polynote
          port:
            number: 8192
  EOF
}
