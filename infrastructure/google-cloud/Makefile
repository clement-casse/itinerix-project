include vars.mk

REQUIRED_EXECUTABLES := curl jq unzip kustomize
CAN_RUN := $(foreach exec,$(REQUIRED_EXECUTABLES), \
	$(if $(shell which $(exec)), "$(exec) found", $(error "The tool $(exec) cannot be found in PATH")) \
)

SYSTEM_NAME := $(shell uname -s | tr A-Z a-z)

.PHONY: \
      terraform-kubectl-provider \
      terraform-kustomization-provider \
      get-linkerd    generate-linkerd-manifests \
      get-strimzi    generate-strimzi-manifest \
      get-ECK        generate-ECK-manifest \
      get-prometheus generate-prometheus-manifest

all: \
      terraform-kubectl-provider \
      generate-linkerd-manifests \
      generate-strimzi-manifest \
      generate-ECK-manifest \
      generate-prometheus-manifest


terraform-kubectl-provider: .terraform/plugins/$(SYSTEM_NAME)_amd64/terraform-provider-kubectl_*
.terraform/plugins/$(SYSTEM_NAME)_amd64/terraform-provider-kubectl_*:
	mkdir -p .terraform/plugins/ && \
      curl -Ls https://api.github.com/repos/gavinbunney/terraform-provider-kubectl/releases/latest \
      | jq -r '.assets[] | select(.browser_download_url | contains("$(SYSTEM_NAME)")) | select(.browser_download_url | contains("amd64")) | .browser_download_url' \
      | xargs -n 1 curl -Lo .terraform/plugins/terraform-provider-kubectl.zip && \
      unzip .terraform/plugins/terraform-provider-kubectl.zip -d .terraform/plugins/$(SYSTEM_NAME)_amd64/ && \
      chmod +x .terraform/plugins/$(SYSTEM_NAME)_amd64/terraform-provider-kubectl* && \
      rm -rf .terraform/plugins/terraform-provider-kubectl.zip && \
      rm -rf .terraform/plugins/$(SYSTEM_NAME)_amd64/{README.md,LICENSE}


terraform-kustomization-provider: .terraform/plugins/$(SYSTEM_NAME)_amd64/terraform-provider-kustomization_*
.terraform/plugins/$(SYSTEM_NAME)_amd64/terraform-provider-kustomization_*:
	mkdir -p .terraform/plugins/$(SYSTEM_NAME)_amd64/
	curl --silent --location \
      https://github.com/kbst/terraform-provider-kustomize/releases/download/$(KUSTOMIZE_PROVIDER_VERSION)/terraform-provider-kustomization-darwin-amd64_$(KUSTOMIZE_PROVIDER_VERSION).tgz \
    | tar --extract --gzip --strip-components=3 --directory="$(dir $@)"
	chmod +x .terraform/plugins/$(SYSTEM_NAME)_amd64/terraform-provider-kustomization*



get-linkerd: .download/linkerd-$(LINKERD2_VERSION)
.download/linkerd-$(LINKERD2_VERSION):
	@echo "Downloading and installing Linkerd Client version $(LINKERD2_VERSION)"
	@mkdir -p ./$@
	@curl --silent --location "https://run.linkerd.io/install" \
      | LINKERD2_VERSION="$(LINKERD2_VERSION)" INSTALLROOT="$(shell pwd)/$@" sh > /dev/null
	@echo "Done !"
LINKERD := $(shell pwd)/.download/linkerd-$(LINKERD2_VERSION)/bin/linkerd

generate-linkerd-manifests: \
	provision/generated-manifests/linkerd-config.yaml \
	provision/generated-manifests/linkerd-controlplane.yaml

provision/generated-manifests/linkerd-config.yaml: linkerd-addon-config.yaml .download/linkerd-$(LINKERD2_VERSION)
	$(LINKERD) install config --ignore-cluster --addon-config $< --linkerd-namespace "$(LINKERD2_NS)" > $@

provision/linkerd-servicemesh/installation-manifests/linkerd-controlplane.yaml: linkerd-addon-config.yaml .download/linkerd-$(LINKERD2_VERSION)
	$(LINKERD) install control-plane --ignore-cluster --addon-config $< --linkerd-namespace "$(LINKERD2_NS)" > $@

provision/generated-manifests/linkerd-controlplane.yaml: provision/linkerd-servicemesh/installation-manifests/linkerd-controlplane.yaml
	kustomize build provision/linkerd-servicemesh/ > $@



get-strimzi: provision/strimzi-operator/installation-manifests
provision/strimzi-operator/installation-manifests:
	@echo "Downloading Strimzi version $(STRIMZI_VERSION)"
	@mkdir -p ./$@
	@curl --silent --location \
      "https://github.com/strimzi/strimzi-kafka-operator/releases/download/$(STRIMZI_VERSION)/strimzi-$(STRIMZI_VERSION).tar.gz" \
      | tar --extract --gzip --directory="$@" --strip-components=2 --exclude=docs/ --exclude=examples/
	@echo "Changing namespace references in YAML files."
	@sed -i 's/namespace: .*/namespace: $(STRIMZI_OPERATOR_NS)/' $@/cluster-operator/*RoleBinding*.yaml
	@echo "Done !"

generate-strimzi-manifest: provision/generated-manifests/strimzi-operator.yaml
provision/generated-manifests/strimzi-operator.yaml: provision/strimzi-operator/installation-manifests
	kustomize build $(dir $<) > $@


get-ECK: provision/generated-manifests/eck-operator.yaml
provision/generated-manifests/eck-operator.yaml:
	@mkdir -p $(dir $@)
	@echo "Downloading Elastic Cloud Kubernetes operator"
	@curl --silent \
      https://download.elastic.co/downloads/eck/$(ECK_VERSION)/all-in-one.yaml \
      > $@
	@echo "Done !"

generate-ECK-manifest: get-ECK



get-prometheus: provision/prometheus-operator/installation-manifests
provision/prometheus-operator/installation-manifests:
	@mkdir -p $@
	@echo "Downloading CoreOS Prometheus Operator"
	@curl --silent \
		https://raw.githubusercontent.com/coreos/prometheus-operator/$(PROM_OPERATOR_VERSION)/example/rbac/prometheus-operator/prometheus-operator-deployment.yaml \
		> $@/prometheus-operator-deployment.yaml
	@curl --silent \
		https://raw.githubusercontent.com/coreos/prometheus-operator/$(PROM_OPERATOR_VERSION)/example/rbac/prometheus-operator/prometheus-operator-cluster-role.yaml \
		> $@/prometheus-operator-cluster-role.yaml
	@curl --silent \
		https://raw.githubusercontent.com/coreos/prometheus-operator/$(PROM_OPERATOR_VERSION)/example/rbac/prometheus-operator/prometheus-operator-cluster-role-binding.yaml \
		> $@/prometheus-operator-cluster-role-binding.yaml
	@curl --silent \
		https://raw.githubusercontent.com/coreos/prometheus-operator/$(PROM_OPERATOR_VERSION)/example/rbac/prometheus-operator/prometheus-operator-service-account.yaml \
		> $@/prometheus-operator-service-account.yaml
	@curl --silent \
		https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/$(PROM_OPERATOR_VERSION)/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml \
		> $@/monitoring.coreos.com_alertmanagers.yaml
	@curl --silent \
		https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/$(PROM_OPERATOR_VERSION)/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml \
		> $@/monitoring.coreos.com_podmonitors.yaml
	@curl --silent \
		https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/$(PROM_OPERATOR_VERSION)/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml \
		> $@/monitoring.coreos.com_prometheuses.yaml
	@curl --silent \
		https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/$(PROM_OPERATOR_VERSION)/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml \
		> $@/monitoring.coreos.com_prometheusrules.yaml
	@curl --silent \
		https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/$(PROM_OPERATOR_VERSION)/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml \
		> $@/monitoring.coreos.com_servicemonitors.yaml
	@curl --silent \
		https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/$(PROM_OPERATOR_VERSION)/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml \
		> $@/monitoring.coreos.com_thanosrulers.yaml
	@echo "Done !"

generate-prometheus-manifest: provision/generated-manifests/prometheus-operator.yaml
provision/generated-manifests/prometheus-operator.yaml: provision/prometheus-operator/installation-manifests
	kustomize build $(dir $<) > $@
