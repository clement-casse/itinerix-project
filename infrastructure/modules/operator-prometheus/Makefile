all: generate-prometheus-manifest

.PHONY: all get-prometheus generate-prometheus-manifest

PROM_OPERATOR_VERSION ?= v0.38.1

get-prometheus: kustomization/installation-manifests
kustomization/installation-manifests:
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
		https://raw.githubusercontent.com/coreos/prometheus-operator/$(PROM_OPERATOR_VERSION)/example/rbac/prometheus-operator/prometheus-operator-service.yaml \
		> $@/prometheus-operator-service.yaml
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

generate-prometheus-manifest: generated-manifests/operator.yaml
generated-manifests/operator.yaml: kustomization/installation-manifests
	@mkdir -p $(dir $@)
	kustomize build $(dir $<) > $@
