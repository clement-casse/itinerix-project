generated-manifests/jaeger.yaml: kustomization/Kustomization
	@mkdir -p $(dir $@)
	kustomize build $(dir $<) > $@