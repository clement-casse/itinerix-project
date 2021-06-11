REQUIRED_EXECUTABLES := curl kustomize kubectl
CAN_RUN := $(foreach exec,$(REQUIRED_EXECUTABLES), \
	$(if $(shell which $(exec)), "$(exec) found", $(error "The tool $(exec) cannot be found in PATH")) \
)

LINKERD2_VERSION ?= stable-2.10.1
LINKERD2_NS ?= linkerd
KUBECONTEXT ?= $(shell kubectl config current-context)
TRACING_ENDPOINT ?= http://my-jaeger-collector.my-jaeger-ns:14268/api/traces


all: install-linkerd-clusterwide-config install-linkerd install-linkerd-extensions

.PHONY: all \
		get-linkerd \
		install-linkerd-clusterwide-config \
		remove-linkerd-clusterwide-config \
		install-linkerd \
		remove-linkerd \
		install-linkerd-extensions \
		remove-linkerd-extensions


get-linkerd: .download/linkerd-$(LINKERD2_VERSION)
.download/linkerd-$(LINKERD2_VERSION):
	@echo "Downloading and installing Linkerd Client version $(LINKERD2_VERSION)"
	@mkdir -p ./$@
	@curl --silent --location "https://run.linkerd.io/install" \
      | LINKERD2_VERSION="$(LINKERD2_VERSION)" INSTALLROOT="$(shell pwd)/$@" sh > /dev/null
	@echo "Done !"
LINKERD := $(shell pwd)/.download/linkerd-$(LINKERD2_VERSION)/bin/linkerd


# LINKERD MULTISTAGE INSTALL WITH KUSTOMIZATION
# References for version 2.10
# • Multi-stage install: https://linkerd.io/2.10/tasks/install/#multi-stage-install
# • Kustomizations: https://linkerd.io/2.10/tasks/customize-install/

install-linkerd-clusterwide-config: .download/linkerd-$(LINKERD2_VERSION)
	$(LINKERD) --context=$(KUBECONTEXT) install config \
	  --ignore-cluster \
	  --linkerd-namespace "$(LINKERD2_NS)" \
	| kubectl --context=$(KUBECONTEXT) apply -f -

remove-linkerd-clusterwide-config: .download/linkerd-$(LINKERD2_VERSION)
	$(LINKERD) --context=$(KUBECONTEXT) install config \
	  --ignore-cluster \
	  --linkerd-namespace "$(LINKERD2_NS)" \
	| kubectl --context=$(KUBECONTEXT) delete -f -

install-linkerd: .download/linkerd-$(LINKERD2_VERSION)
	@echo "RUNNING TARGET <$@>"
	$(LINKERD) --context=$(KUBECONTEXT) install control-plane \
	  --ignore-cluster \
	  --linkerd-namespace "$(LINKERD2_NS)" \
	| kubectl --context=$(KUBECONTEXT) apply -n "$(LINKERD2_NS)" -f -



kustomization/installation-manifests/linkerd-viz-components.yaml: .download/linkerd-$(LINKERD2_VERSION)
	@mkdir -p ./$(dir $@)
	$(LINKERD) --context=$(KUBECONTEXT) viz install \
	  --set linkerdNamespace=$(LINKERD2_NS) \
	  --linkerd-namespace "$(LINKERD2_NS)" > $@

kustomization/installation-manifests/linkerd-jaeger.yaml: .download/linkerd-$(LINKERD2_VERSION)
	@mkdir -p ./$(dir $@)
	$(LINKERD) --context=$(KUBECONTEXT) viz install \
	  --set collector.jaegerAddr="$(TRACING_ENDPOINT)" \
	  --set installNamespace=false \
	  --linkerd-namespace "$(LINKERD2_NS)" > $@

install-linkerd-extensions: \
		kustomization/installation-manifests/linkerd-viz-components.yaml \
		kustomization/installation-manifests/linkerd-jaeger.yaml
	@echo "RUNNING TARGET <$@>"
	kustomize build kustomization/
	| kubectl --context=$(KUBECONTEXT) apply -n "$(LINKERD2_NS)" -f -

remove-linkerd-extensions: \
		kustomization/installation-manifests/linkerd-viz-components.yaml \
		kustomization/installation-manifests/linkerd-jaeger.yaml
	@echo "RUNNING TARGET <$@>"
	kustomize build kustomization/
	  | kubectl --context=$(KUBECONTEXT) delete -n "$(LINKERD2_NS)" -f -
