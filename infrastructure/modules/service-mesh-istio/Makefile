REQUIRED_EXECUTABLES := curl kubectl
CAN_RUN := $(foreach exec,$(REQUIRED_EXECUTABLES), \
	$(if $(shell which $(exec)), "$(exec) found", $(error "The tool $(exec) cannot be found in PATH")) \
)

ISTIO_VERSION ?= 1.9.0
ISTIO_NAMESPACE ?= istio-system
KUBECONTEXT ?= $(shell kubectl config current-context)

.PHONY: get-istio install-istio uninstall-istio purge

get-istio: .download/istio-$(ISTIO_VERSION)/
.download/istio-$(ISTIO_VERSION)/:
	@echo "Downloading and installing Istio Client version $(ISTIO_VERSION)"
	@mkdir -p ./$@
	@cd .download/ && ISTIO_VERSION="$(ISTIO_VERSION)" curl --silent --location "https://istio.io/downloadIstio" \
	  | ISTIO_VERSION="$(ISTIO_VERSION)" sh -
	@echo "Done !"

ISTIOCTL := $(realpath .download)/istio-$(ISTIO_VERSION)/bin/istioctl


install-istio: k8s-manifests/istio-operator.yaml
	@echo "RUNNING TARGET <$@>"
	$(ISTIOCTL) --context=$(KUBECONTEXT) install \
	  --skip-confirmation \
	  --filename $< \
	  --set namespace=$(ISTIO_NAMESPACE)


uninstall-istio: k8s-manifests/istio-operator.yaml
	@echo "RUNNING TARGET <$@>"
	$(ISTIOCTL) manifest generate --filename $< --set namespace=$(ISTIO_NAMESPACE) \
	  | kubectl --context=$(KUBECONTEXT) delete --ignore-not-found=true -f - \
	  && kubectl delete namespace $(ISTIO_NAMESPACE)


purge:
	rm -rf .download/
