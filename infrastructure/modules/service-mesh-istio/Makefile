REQUIRED_EXECUTABLES := curl
CAN_RUN := $(foreach exec,$(REQUIRED_EXECUTABLES), \
	$(if $(shell which $(exec)), "$(exec) found", $(error "The tool $(exec) cannot be found in PATH")) \
)

ISTIO_VERSION ?= 1.6.11

all: generate-istio-manifests

.PHONY: get-istio generate-istio-manifests

get-istio: .download/istio-$(ISTIO_VERSION)/
.download/istio-$(ISTIO_VERSION)/:
	@echo "Downloading and installing Istio Client version $(ISTIO_VERSION)"
	@mkdir -p ./$@
	@cd .download/ && ISTIO_VERSION="$(ISTIO_VERSION)" curl --silent --location "https://istio.io/downloadIstio" \
	  | ISTIO_VERSION="$(ISTIO_VERSION)" sh -
	@echo "Done !"

ISTIOCTL := $(shell pwd)/.download/istio-$(ISTIO_VERSION)/bin/istioctl

generate-istio-manifests: installation-manifests/Base
installation-manifests/Base: istio-operator.yaml .download/istio-$(ISTIO_VERSION)/
	$(ISTIOCTL) manifest generate --filename "$<" --output '$(dir $(dir $@))'
