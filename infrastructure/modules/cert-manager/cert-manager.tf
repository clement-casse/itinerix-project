## FOR DNS01 Challenge
resource "google_service_account" "dns01_service_account" {
  account_id   = "dns01-solver"
  display_name = "dns01-solver"
}

resource "google_project_iam_binding" "project" {
  project = var.project
  role    = "roles/dns.admin"

  members = [
    "serviceAccount:${google_service_account.dns01_service_account.email}",
  ]
}

resource "google_service_account_key" "dns01_service_account_key" {
  service_account_id = google_service_account.dns01_service_account.name
}

## Install cert-manager from kubectl
resource "null_resource" "cert_manager" {
  triggers = {
    certmanager_version = var.certmanager_version
  }

  provisioner "local-exec" {
    command     = "gcloud container clusters get-credentials $CLUSTER_NAME --region $REGION"

    environment = {
      CLUSTER_NAME = var.cluster_name
      REGION       = var.region
    }
  }

  provisioner "local-exec" {
    command     = "kubectl --context=$CONTEXT apply --filename https://github.com/jetstack/cert-manager/releases/download/$CERTMANAGER_VERSION/cert-manager.yaml"
    working_dir = path.module

    environment = {
      CERTMANAGER_VERSION = var.certmanager_version
      CONTEXT             = "gke_${var.project}_${var.region}_${var.cluster_name}"
    }
  }
}

## Create a K8S secret for Operations on DNS performed by certmanager/ACME with DNS01 challenge
#  TODO Switch to Workload Identity instead of JSON key from Service account
resource "kubernetes_secret" "dns01sover_credentials" {
  metadata {
    name = "clouddns-dns01-solver-svc-acct"
    namespace = "cert-manager"
  }
  data = {
    "key.json" = base64decode(google_service_account_key.dns01_service_account_key.private_key)
  }

  depends_on = [ null_resource.cert_manager ]
}

resource "kubectl_manifest" "cert_manager_acme_clusterissuers" {
  yaml_body = <<-EOF
  ---
  apiVersion: cert-manager.io/v1
  kind: ClusterIssuer
  metadata:
    name: letsencrypt-staging
  spec:
    acme:
      email: "${var.acme_email}"
      server: https://acme-staging-v02.api.letsencrypt.org/directory
      privateKeySecretRef:
        name: acme-issuer-account-key
      solvers:
      - http01:
          ingress:
            class: istio
      - dns01:
          cloudDNS:
            project: ${var.project}
            serviceAccountSecretRef:
              name: ${kubernetes_secret.dns01sover_credentials.metadata.0.name}
              key: key.json
  ---
  apiVersion: cert-manager.io/v1
  kind: ClusterIssuer
  metadata:
    name: letsencrypt-prod
  spec:
    acme:
      email: "${var.acme_email}"
      server: https://acme-v02.api.letsencrypt.org/directory
      privateKeySecretRef:
        name: acme-prod-issuer-account-key
      solvers:
      - http01:
          ingress:
            class: istio
      - dns01:
          cloudDNS:
            project: ${var.project}
            serviceAccountSecretRef:
              name: ${kubernetes_secret.dns01sover_credentials.metadata.0.name}
              key: key.json
  EOF
}


resource "kubectl_manifest" "certificate" {
  for_each = toset(var.certificates_to_create)

  yaml_body = <<-EOF
  apiVersion: cert-manager.io/v1
  kind: Certificate
  metadata:
    name: ${split(".", each.key).0}-ingress-cert
    namespace: istio-system
  spec:
    secretName: ${split(".", each.key).0}-ingress-cert
    commonName: "${each.key}"
    dnsNames:
    - "${each.key}"
    issuerRef:
      name: letsencrypt-staging
      kind: ClusterIssuer
  EOF
}
