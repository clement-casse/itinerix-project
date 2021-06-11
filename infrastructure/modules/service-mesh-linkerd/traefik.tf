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
  ---
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
  ---
  apiVersion: apiextensions.k8s.io/v1beta1
  kind: CustomResourceDefinition
  metadata:
    name: serverstransports.traefik.containo.us
  spec:
    group: traefik.containo.us
    version: v1alpha1
    names:
      kind: ServersTransport
      plural: serverstransports
      singular: serverstransport
    scope: Namespaced
  YAML
}

resource "kubectl_manifest" "traefik_rbac" {
  yaml_body = <<-EOF
  ---
  apiVersion: v1
  kind: ServiceAccount
  metadata:
    name: traefik
    namespace: ${kubernetes_namespace.traefik_ns.metadata.0.name}

  ---
  apiVersion: rbac.authorization.k8s.io/v1
  kind: ClusterRole
  metadata:
    name: traefik-ingress-controller
  rules:
  - apiGroups: [ "" ]
    resources: [ "services", "endpoints", "secrets" ]
    verbs: [ "get", "list", "watch" ]

  - apiGroups: [ "extensions" ]
    resources: [ "ingresses" ]
    verbs: [ "get", "list", "watch" ]

  - apiGroups: [ "extensions" ]
    resources: [ "ingresses/status" ]
    verbs: [ "update" ]

  - apiGroups: [ "traefik.containo.us" ]
    resources:
    - middlewares
    - ingressroutes
    - traefikservices
    - ingressroutetcps
    - ingressrouteudps
    - tlsoptions
    - tlsstores
    verbs: [ "get", "list", "watch" ]


  ---
  kind: ClusterRoleBinding
  apiVersion: rbac.authorization.k8s.io/v1
  metadata:
    name: traefik
  roleRef:
    apiGroup: rbac.authorization.k8s.io
    kind: ClusterRole
    name: traefik-ingress-controller
  subjects:
  - kind: ServiceAccount
    name: traefik
    namespace: ${kubernetes_namespace.traefik_ns.metadata.0.name}
  EOF
}

resource "kubernetes_config_map" "traefik_config" {
  metadata {
    name      = "traefik-config"
    namespace = kubernetes_namespace.traefik_ns.metadata.0.name
  }

  data = {
    "traefik.toml" = <<-EOF
    [log]
      level = "INFO"

    [entryPoints]
      [entryPoints.http]
        address = ":8000"

      [entryPoints.https]
        address = ":4443"
        [entryPoints.https.http.tls]
          certResolver = "default"

      [entryPoints.traefik-internal]
        address = ":9000"

      [entryPoints.http-bolt]
        address = ":7687"

    [ping]
      entryPoint = "traefik-internal"
    
    [api]
      dashboard = true

    [metrics]
      [metrics.prometheus]
        buckets = [0.1, 0.3, 1.2, 5.0]
        entrypoint = "traefik-internal"
    
    [tracing]
      [tracing.jaeger]
        localAgentHostPort = "127.0.0.1:6831"

    [providers]
      [providers.kubernetesCRD]
        namespaces = [ ]
    EOF
  }
}

resource "kubernetes_config_map" "otel_config" {
  metadata {
    name      = "otel-agent-config"
    namespace = kubernetes_namespace.traefik_ns.metadata.0.name
  }

  data = {
    "config.yaml" = <<-EOF
    receivers:
      opencensus:
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

      resource:
        attributes:
        - key: service.name
          action: upsert
          value: $${SERVICE_NAME}
        - key: service.instance.id
          action: upsert
          value: $${K8S_POD_NAME}
        - key: k8s.pod.name
          action: upsert
          value: $${K8S_POD_NAME}
        - key: k8s.pod.uid
          action: upsert
          value: $${K8S_POD_UID}
        - key: k8s.namespace.name
          action: upsert
          value: $${K8S_NAMESPACE_NAME}
        - key: k8s.pod.ip
          action: upsert
          value: $${K8S_POD_IP}
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
          value: europe-west1
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
        endpoint: jaeger-collector.${var.tracing_namespace}.svc.cluster.local:14250

    service:
      pipelines:
        traces:
          receivers: [jaeger, opencensus]
          processors: [batch, resource]
          exporters: [jaeger]
    EOF
  }
}

resource "kubectl_manifest" "traefik_deploy" {
  yaml_body = <<-EOF
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: traefik
    namespace: ${kubernetes_namespace.traefik_ns.metadata.0.name}
    labels:
      component: traefik
  spec:
    replicas: 1
    selector:
      matchLabels:
        component: traefik
    template:
      metadata:
        labels:
          component: traefik
      spec:
        serviceAccountName: traefik
        securityContext:
          fsGroup: 65532
        containers:
        - name: traefik
          image: traefik:v2.4
          ports:
          - containerPort: 8000
            name: http
          - containerPort: 4443
            name: https
          - containerPort: 9000
            name: traefik
          - containerPort: 7687
            name: http-bolt
          volumeMounts:
          - mountPath: /etc/traefik/traefik.toml
            name: traefik-config-volume
            subPath: traefik.toml
            readOnly: true
          args: [ "--configFile=/etc/traefik/traefik.toml" ]
          readinessProbe:
            httpGet:
              path: /ping
              port: traefik
            failureThreshold: 1
            initialDelaySeconds: 10
            timeoutSeconds: 2
          livenessProbe:
            httpGet:
              path: /ping
              port: traefik
            initialDelaySeconds: 10
            timeoutSeconds: 2
          securityContext:
            capabilities:
              drop:
              - ALL
            readOnlyRootFilesystem: true
            runAsUser: 65532
            runAsGroup: 65532
            runAsNonRoot: true
          resources:
            requests:
              cpu: 100m
              memory: 100Mi
            limits:
              cpu: 200m
              memory: 200Mi
        - name: jaeger-agent
          image: jaegertracing/jaeger-opentelemetry-agent:latest
          imagePullPolicy: IfNotPresent
          ports:
          - containerPort: 5778
            name: http-config-ag
            protocol: TCP
          - containerPort: 6831
            name: jg-compact-trft
            protocol: UDP
          - containerPort: 6832
            name: jg-binary-trft
            protocol: UDP
          - containerPort: 14250
            name: grpc-traces
            protocol: TCP
          volumeMounts:
          - mountPath: /etc/otel/config.yaml
            name: otel-agent-config-volume
            subPath: config.yaml
            readOnly: true
          env:
          - name: SERVICE_NAME
            value: traefik
          - name: K8S_NAMESPACE_NAME
            valueFrom:
              fieldRef:
                fieldPath: metadata.namespace
          - name: K8S_CLUSTER_NAME
            value: k8s
          - name: K8S_POD_UID
            valueFrom:
              fieldRef:
                fieldPath: metadata.uid
          - name: K8S_POD_NAME
            valueFrom:
              fieldRef:
                fieldPath: metadata.name
          - name: K8S_POD_IP
            valueFrom:
              fieldRef:
                fieldPath: status.podIP
          - name: HOST_IP
            valueFrom:
              fieldRef:
                fieldPath: status.hostIP
          - name: HOST_NAME
            valueFrom:
              fieldRef:
                fieldPath: spec.nodeName
          args: [
            "--http-server.host-port=:5778",
            "--config=/etc/otel/config.yaml"
          ]
          securityContext:
            capabilities:
              drop:
              - ALL
            readOnlyRootFilesystem: true
            runAsUser: 65532
            runAsGroup: 65532
            runAsNonRoot: true
          resources:
            requests:
              cpu: 5m
              memory: 10Mi
            limits:
              cpu: 50m
              memory: 100Mi
        volumes:
        - name: traefik-config-volume
          configMap:
            name: ${kubernetes_config_map.traefik_config.metadata.0.name}
            namespace: ${kubernetes_namespace.traefik_ns.metadata.0.name}
        - name: otel-agent-config-volume
          configMap:
            name: ${kubernetes_config_map.otel_config.metadata.0.name}
            namespace: ${kubernetes_namespace.traefik_ns.metadata.0.name}
  EOF
}

