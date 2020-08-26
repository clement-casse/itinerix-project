# *Google Cloud Engine* Cluster Provisioning

This directory hosts a Terraform project that provision a Kubernetes Cluster with two node-pools (for the sake of cross zone latency measurements), a public IP for the reverse-proxy, as well as domain name to serve publicly this project.

**Before running Terraform, some manifests need to be generated first, their creation is handled in the `Makefile`, run `make all` to download and tune operator deployments.**
These manifests hold mainly the configuration of some operators:

- **Prometheus Operator** that defines prometheus CRDs and automates their deployments
- **ECK Operator** that defines Elasticsearch CRDs and manage their lifecycle (to be used by Jaeger in the case of a *Production* or a *Streaming* deployment)
- **Strimzi Operator** that defines Kafka, Zookeeper, Topics, etc. CRDs to ease the management of Kafka Cluster (to be used by Jaeger in the case of a *Streaming* deployment)
- ~~**Jaeger operator**~~ Jaeger Operator has been discarded in favor of a custom installation to be able to manually configure OpenTelemetry options.
- **Linkerd** is also installed to grant a better observability on service-to-service communications and to flesh tracing data with network-level measurements.

Not all of these operators are mandatory, however they are all installed by Terraform.

## Details on automation

The automation pipeline to make terraform install is a bit clunky:

1. In the `Makefile`, targets named `get-$(OPERATOR_NAME)` downloads public base manifests used by operators (according to their installation procedure) and place them in a working directory (`./provision/linkerd-servicemesh/installation-manifests`, `./provision/prometheus-operator/installation-manifests`, `./provision/strimzi-operator/installation-manifests`).
1. These manifests are imported by a `Kustomization` as resources and are then patched to match the target-cluster requirements. `Makefile` targets named `generate-$(OPERATOR)-manifest` call `kustomize` to build manifests from these kustomization, into the directory `./provision/generated-manifests/`.
1. When terraform runs the module `provision`, the [`kubectl` terraform provider](https://github.com/gavinbunney/terraform-provider-kubectl) imports these manifests `data` (cf. file operators.tf).

**Note:**
The [terraform provider Kustomize](https://github.com/kbst/terraform-provider-kustomize) has been tested to simplify this workflow by avoiding the second step and directly calling the Kustomization itself, however it appeared that the provider was not idempotent, resources were often recreated, however no more investigation has been done on the cause of this issue.
