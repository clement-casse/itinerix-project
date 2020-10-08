REQUIRED_EXECUTABLES := curl kustomize
CAN_RUN := $(foreach exec,$(REQUIRED_EXECUTABLES), \
	$(if $(shell which $(exec)), "$(exec) found", $(error "The tool $(exec) cannot be found in PATH")) \
)

LINKERD2_VERSION ?= stable-2.8.1
LINKERD2_NS ?= linkerd

all: generate-linkerd-manifests

.PHONY: get-linkerd generate-linkerd-manifests

get-linkerd: .download/linkerd-$(LINKERD2_VERSION)
.download/linkerd-$(LINKERD2_VERSION):
	@echo "Downloading and installing Linkerd Client version $(LINKERD2_VERSION)"
	@mkdir -p ./$@
	@curl --silent --location "https://run.linkerd.io/install" \
      | LINKERD2_VERSION="$(LINKERD2_VERSION)" INSTALLROOT="$(shell pwd)/$@" sh > /dev/null
	@echo "Done !"
LINKERD := $(shell pwd)/.download/linkerd-$(LINKERD2_VERSION)/bin/linkerd

generate-linkerd-manifests: \
	generated-manifests/linkerd-config.yaml \
	generated-manifests/linkerd-controlplane.yaml

generated-manifests/linkerd-config.yaml: .download/linkerd-$(LINKERD2_VERSION)
	@mkdir -p ./$(dir $@)
	$(LINKERD) install config --ignore-cluster --linkerd-namespace "$(LINKERD2_NS)" > $@

kustomization/installation-manifests/linkerd-controlplane.yaml: .download/linkerd-$(LINKERD2_VERSION)
	@mkdir -p ./$(dir $@)
	$(LINKERD) install control-plane --ignore-cluster --linkerd-namespace "$(LINKERD2_NS)" > $@

generated-manifests/linkerd-controlplane.yaml: #kustomization/installation-manifests/linkerd-controlplane.yaml
	#kustomize build kustomization/ > $@
	$(LINKERD) install control-plane --ignore-cluster --linkerd-namespace "$(LINKERD2_NS)" > $@
