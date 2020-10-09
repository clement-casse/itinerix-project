all: generate-strimzi-manifest

.PHONY: all get-strimzi generate-strimzi-manifest

STRIMZI_VERSION ?= 0.19.0
STRIMZI_OPERATOR_NS ?= strimzi-system

get-strimzi: kustomization/installation-manifests
kustomization/installation-manifests:
	@echo "Downloading Strimzi version $(STRIMZI_VERSION)"
	@mkdir -p ./$@
	@curl --silent --location \
      "https://github.com/strimzi/strimzi-kafka-operator/releases/download/$(STRIMZI_VERSION)/strimzi-$(STRIMZI_VERSION).tar.gz" \
      | tar --extract --gzip --directory="$@" --strip-components=2 --exclude=docs/ --exclude=examples/
	@echo "Changing namespace references in YAML files."
	@sed -i 's/namespace: .*/namespace: $(STRIMZI_OPERATOR_NS)/' $@/cluster-operator/*RoleBinding*.yaml
	@echo "Done !"

generate-strimzi-manifest: generated-manifests/operator.yaml
generated-manifests/operator.yaml: kustomization/installation-manifests
	@mkdir -p $(dir $@)
	kustomize build $(dir $<) > $@
