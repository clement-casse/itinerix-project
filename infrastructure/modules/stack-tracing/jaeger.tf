data "kubernetes_namespace" "jaeger_ns" {
  metadata {
    name = var.jaeger_install_ns
  }
}

resource "null_resource" "jaeger_otel_kustomization" {
  provisioner "local-exec" {
    command     = <<-SCRIPT
      kustomize build ./kustomization \
      | kubectl apply --namespace=$JAEGER_NAMESPACE --context=$CONTEXT --filename -
    SCRIPT
    working_dir = path.module

    environment = {
      JAEGER_NAMESPACE = data.kubernetes_namespace.jaeger_ns.metadata.0.name
      CONTEXT          = "gke_${var.project}_${var.region}_${var.cluster_name}"
    }
  }
}


data "kubernetes_service" "jaeger_collector" {
  metadata {
    name      = "jaeger-collector"
    namespace = data.kubernetes_namespace.jaeger_ns.metadata.0.name
  }

  depends_on = [ null_resource.jaeger_otel_kustomization ]
}

resource "kubernetes_service_account" "node_reader" {
  metadata {
    name      = "node-reader"
    namespace = data.kubernetes_namespace.jaeger_ns.metadata.0.name
  }
}

resource "kubernetes_cluster_role" "node_reader" {
  metadata {
    name = "node-reader"
  }
  rule {
    api_groups = [ "" ]
    resources  = [ "*" ]
    verbs      = [ "get", "list", "watch" ]
  }
}

resource "kubernetes_cluster_role_binding" "node_reader" {
  metadata {
    name = "node-reader"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.node_reader.metadata.0.name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.node_reader.metadata.0.name
    namespace = kubernetes_service_account.node_reader.metadata.0.namespace
  }
}


resource "kubectl_manifest" "service_local_otel_agent" {
  yaml_body = <<-EOF
  apiVersion: v1
  kind: Service
  metadata:
    name: otel-fwd
    namespace: ${data.kubernetes_namespace.jaeger_ns.metadata.0.name}
  spec:
    selector:
      component: otel-node-agent
    ports:
    - name: http-zipkin
      port: 9411
    - name: grpc-jaeger
      port: 14250
    - name: c-tchan-trft
      port: 14267
    - name: http-c-binary-trft
      port: 14268
    - name: oc
      port: 55678
    topologyKeys:
    - "kubernetes.io/hostname"
  EOF
}

resource "kubernetes_daemonset" "otel_agent" {
  metadata {
    name      = "otel-node-forwarder"
    namespace = data.kubernetes_namespace.jaeger_ns.metadata.0.name
    labels = {
      "component" = "otel-node-agent"
    }
  }
  spec {
    selector {
      match_labels = {
        "component" = "otel-node-agent"
      }
    }
    template {
      metadata {
        labels = {
          "component" = "otel-node-agent"
        }
      }
      spec {
        service_account_name = kubernetes_service_account.node_reader.metadata.0.name
        init_container {
          name  = "init-otel-cfg"
          image = "bitnami/kubectl"

          volume_mount {
            mount_path = "/etc/otel/config.yaml"
            name       = "otel-agent-config-volume"
            sub_path   = "config.yaml"
            read_only  = true
          }
          volume_mount {
            mount_path = "/tmp"
            name       = "new-otel-agent-config-volume"
          }

          env {
            name = "NODE_NAME"
            value_from {
              field_ref {
                field_path = "spec.nodeName"
              }
            }
          }

          command = [ 
            "sh", "-c",
            <<-EOSCRIPT
              set -x;
              export ZONE_NAME=$(kubectl get no "$NODE_NAME" -o go-template --template="{{.metadata.labels.zone}}");
              sed -e "s/ZONE_NAME_TO_REPLACE/$ZONE_NAME/" /etc/otel/config.yaml > /tmp/config.yaml;
            EOSCRIPT
          ]
        }

        container {
          image = "jaegertracing/jaeger-opentelemetry-agent:latest"
          name  = "node-local-otel-agent"

          port {
            name           = "http-config-ag"
            container_port = 5778
            protocol       = "TCP"
          }
          port {
            name           = "jg-compact-trft"
            container_port = 6831
            protocol       = "UDP"
          }
          port {
            name           = "jg-binary-trft"
            container_port = 6832
            protocol       = "UDP"
          }
          port {
            name           = "http-zipkin"
            container_port = 9411
            protocol       = "TCP"
          }
          port {
            name           = "http-traces"
            container_port = 14268
            protocol       = "TCP"
          }
          port {
            name           = "grpc-traces"
            container_port = 14250
            protocol       = "TCP"
          }
          port {
            name           = "oc"
            container_port = 55678
            protocol       = "TCP"
          }

          volume_mount {
            mount_path = "/etc/otel/config.yaml"
            name       = "new-otel-agent-config-volume"
            sub_path   = "config.yaml"
            read_only  = true
          }

          args = [
            "--http-server.host-port=:5778",
            "--config=/etc/otel/config.yaml"
          ]

          env {
            name  = "K8S_CLUSTER_NAME"
            value = var.cluster_name
          }
          env {
            name = "HOST_IP"
            value_from {
              field_ref {
                field_path = "status.hostIP"
              }
            }
          }
          env {
            name = "HOST_NAME"
            value_from {
              field_ref {
                field_path = "spec.nodeName"
              }
            }
          }

          security_context {
            capabilities {
              drop = [ "ALL" ]
            }
            read_only_root_filesystem = true
            run_as_non_root           = true
            run_as_user               = "65532"
            run_as_group              = "65532"
          }

          resources {
            requests = {
              "cpu"    = "5m"
              "memory" = "10Mi"
            }
            limits = {
              "cpu"    = "50m"
              "memory" = "100Mi"
            }
          }
        }

        volume {
          name = "new-otel-agent-config-volume"
          empty_dir {}
        }
        volume {
          name = "otel-agent-config-volume"
          config_map {
            name = kubernetes_config_map.otel_config.metadata.0.name
          }
        }
      }
    }
  }
}

resource "kubernetes_config_map" "otel_config" {
  metadata {
    name      = "otel-agent-config"
    namespace = data.kubernetes_namespace.jaeger_ns.metadata.0.name
  }

  data = {
    "config.yaml" = <<-EOF
    receivers:
      opencensus:
      zipkin:
      jaeger:
        protocols:
          grpc:
          thrift_binary:
          thrift_compact:
          thrift_http:

    processors:
      batch:
        timeout: 5s
        send_batch_size: 128

      span:
        exclude:
          match_type: regexp
          span_names: [ "jaeger-query.istio-system.svc.cluster.local:16686/jaeger"]

      resource:
        attributes:
        - key: k8s.cluster.name
          action: upsert
          value: $${K8S_CLUSTER_NAME}
        - key: host.name
          action: upsert
          value: $${HOST_NAME}
        - key: host.ip
          action: upsert
          value: $${HOST_IP}
        - key: cloud.provider
          action: upsert
          value: gcp
        - key: cloud.region
          action: upsert
          value: ${var.region}
        - key: cloud.zone
          action: upsert
          value: ZONE_NAME_TO_REPLACE

        - key: experimentation
          action: delete
        - key: app
          action: delete
        - key: pod-template-hash
          action: delete
        - key: opencensus.starttime
          action: delete
        - key: opencensus.pid
          action: delete

    exporters:
      jaeger:
        endpoint: ${data.kubernetes_service.jaeger_collector.metadata.0.name}.${data.kubernetes_namespace.jaeger_ns.metadata.0.name}.svc.cluster.local:14250

    service:
      pipelines:
        traces:
          receivers: [jaeger, opencensus, zipkin]
          processors: [batch, resource]
          exporters: [jaeger]
    EOF
  }
}

###
### ISTIO SPECIFIC FOR INGRESS TRAFFIC
###
resource "kubectl_manifest" "monitoring_ingress_cfg" {
  yaml_body = <<-EOF
  ---
  apiVersion: networking.istio.io/v1alpha3
  kind: Gateway
  metadata:
    name: monitoring-gateway
    namespace: ${data.kubernetes_namespace.jaeger_ns.metadata.0.name}
  spec:
    selector:
      istio: ingressgateway
    servers:
    - hosts: [ "${var.jaeger_host}" ]
      port:
        number: 80
        name: http
        protocol: HTTP
      tls:
        httpsRedirect: true
    - hosts: [ "${var.jaeger_host}" ]
      port:
        number: 443
        name: https
        protocol: HTTPS
      tls:
        mode: SIMPLE
        credentialName: monitoring-ingress-cert
  ---
  apiVersion: networking.istio.io/v1alpha3
  kind: VirtualService
  metadata:
    name: jaeger-ingress
    namespace: ${data.kubernetes_namespace.jaeger_ns.metadata.0.name}
  spec:
    hosts: [ "${var.jaeger_host}" ]
    gateways:
    - monitoring-gateway
    http:
    - name: jaeger-route
      match:
      - uri:
          prefix: "${var.jaeger_pathprefix}"
      route:
      - destination:
          host: jaeger-query
          port:
            number: 16686
  EOF
}
