generated-manifests/notebook.yaml: kustomization/Kustomization
	@mkdir -p $(dir $@)
	kustomize build $(dir $<) > $@