# Cert-Manager Distribution

.ONESHELL:
.SHELLFLAGS += -e

VERSION:=$(shell grep 'version:' modules/cert-manager/values.cue | awk '{ print $$2}' | tr -d '"')
DEBUG_VERSION:=$(shell grep 'version:' modules/cert-manager/debug_values.cue | awk '{ print $$2}' | tr -d '"')
ORG:="nalum"
REPO:="cert-manager-bundle"
CERT_MANAGER_VERSION:=1.13.2
MV:=1.13.2
KV:=1.28.0
NAME:="cert-manager"
NAMESPACE:="cert-manager"

.PHONY: help
help:  ## Display this help menu
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
	@echo "$(VERSION)"

.PHONY: tools
tools: ## Install cue, kind, kubectl, Timoni and FLux CLIs
	brew bundle

.PHONY: fmt
fmt: ## Format all CUE definitions
	@cue fmt ./bundles/...
	@cue fmt ./modules/cert-manager/...

.PHONY: gen
gen: ## Print the CUE generated objects
	@cd modules/cert-manager
	@cue cmd -t name=$(NAME) -t namespace=$(NAMESPACE) -t mv=v$(MV) -t kv=$(KV) build

.PHONY: vet-debug
vet-debug:
	@cd modules/cert-manager
	@timoni mod vet --debug --namespace $(NAMESPACE) --name $(NAME)

.PHONY: vet
vet:
	@cd modules/cert-manager
	@timoni mod vet --namespace $(NAMESPACE) --name $(NAME)

.PHONY: ls
ls: ## List the CUE generated objects
	@cd modules/cert-manager
	@cue cmd -t name=$(NAME) -t namespace=$(NAMESPACE) -t mv=v$(MV) -t kv=$(KV) ls

.PHONY: gen-debug-files
gen-debug-files: ## Generate resources and write to files
	@mkdir -p output
	@timoni -n $(NAMESPACE) build $(NAME) ./modules/cert-manager -f ./modules/cert-manager/debug_values.cue -v=$(DEBUG_VERSION) > all.yaml
	@yq --yaml-output '. | select(.kind == "ClusterRole")' all.yaml > output/ClusterRole.yaml
	@yq --yaml-output '. | select(.kind == "ClusterRoleBinding")' all.yaml > output/ClusterRoleBinding.yaml
	@yq --yaml-output '. | select(.kind == "ConfigMap")' all.yaml > output/ConfigMap.yaml
	@yq --yaml-output '. | select(.kind == "CustomResourceDefinition")' all.yaml > output/CustomResourceDefinition.yaml
	@yq --yaml-output '. | select(.kind == "Deployment")' all.yaml > output/Deployment.yaml
	@yq --yaml-output '. | select(.kind == "Job")' all.yaml > output/Job.yaml
	@yq --yaml-output '. | select(.kind == "MutatingWebhookConfiguration")' all.yaml > output/MutatingWebhookConfiguration.yaml
	@yq --yaml-output '. | select(.kind == "Namespace")' all.yaml > output/Namespace.yaml
	@yq --yaml-output '. | select(.kind == "NetworkPolicy")' all.yaml > output/NetworkPolicy.yaml
	#@yq --yaml-output '. | select(.kind == "PodDisruptionBudget")' all.yaml > output/PodDisruptionBudget.yaml
	#@yq --yaml-output '. | select(.kind == "PodSecurityPolicy")' all.yaml > output/PodSecurityPolicy.yaml
	#@yq --yaml-output '. | select(.kind == "Role")' all.yaml > output/Role.yaml
	#@yq --yaml-output '. | select(.kind == "RoleBinding")' all.yaml > output/RoleBinding.yaml
	@yq --yaml-output '. | select(.kind == "Service")' all.yaml > output/Service.yaml
	@yq --yaml-output '. | select(.kind == "ServiceAccount")' all.yaml > output/ServiceAccount.yaml
	#@yq --yaml-output '. | select(.kind == "ServiceMonitor")' all.yaml > output/ServiceMonitor.yaml
	@yq --yaml-output '. | select(.kind == "ValidatingWebhookConfiguration")' all.yaml > output/ValidatingWebhookConfiguration.yaml
	@rm all.yaml

.PHONY: gen-files
gen-files: ## Generate resources and write to files
	@mkdir -p output
	@timoni -n $(NAMESPACE) build $(NAME) ./modules/cert-manager -v=$(VERSION) > all.yaml
	@yq --yaml-output '. | select(.kind == "ClusterRole")' all.yaml > output/ClusterRole.yaml
	@yq --yaml-output '. | select(.kind == "ClusterRoleBinding")' all.yaml > output/ClusterRoleBinding.yaml
	@yq --yaml-output '. | select(.kind == "ConfigMap")' all.yaml > output/ConfigMap.yaml
	@yq --yaml-output '. | select(.kind == "CustomResourceDefinition")' all.yaml > output/CustomResourceDefinition.yaml
	@yq --yaml-output '. | select(.kind == "Deployment")' all.yaml > output/Deployment.yaml
	@yq --yaml-output '. | select(.kind == "Job")' all.yaml > output/Job.yaml
	@yq --yaml-output '. | select(.kind == "MutatingWebhookConfiguration")' all.yaml > output/MutatingWebhookConfiguration.yaml
	@yq --yaml-output '. | select(.kind == "Namespace")' all.yaml > output/Namespace.yaml
	@yq --yaml-output '. | select(.kind == "NetworkPolicy")' all.yaml > output/NetworkPolicy.yaml
	@yq --yaml-output '. | select(.kind == "PodDisruptionBudget")' all.yaml > output/PodDisruptionBudget.yaml
	@yq --yaml-output '. | select(.kind == "PodSecurityPolicy")' all.yaml > output/PodSecurityPolicy.yaml
	@yq --yaml-output '. | select(.kind == "Role")' all.yaml > output/Role.yaml
	@yq --yaml-output '. | select(.kind == "RoleBinding")' all.yaml > output/RoleBinding.yaml
	@yq --yaml-output '. | select(.kind == "Service")' all.yaml > output/Service.yaml
	@yq --yaml-output '. | select(.kind == "ServiceAccount")' all.yaml > output/ServiceAccount.yaml
	@yq --yaml-output '. | select(.kind == "ServiceMonitor")' all.yaml > output/ServiceMonitor.yaml
	@yq --yaml-output '. | select(.kind == "ValidatingWebhookConfiguration")' all.yaml > output/ValidatingWebhookConfiguration.yaml
	@rm all.yaml

.PHONY: push-mod
push-mod: ## Push the Timoni modules to GHCR
	@timoni mod push ./modules/cert-manager oci://ghcr.io/$(ORG)/modules/cert-manager -v=$(VERSION:v%=%) --latest \
		--sign cosign \
		-a 'org.opencontainers.image.source=https://github.com/$(ORG)/$(REPO)'  \
		-a 'org.opencontainers.image.licenses=Apache-2.0' \
		-a 'org.opencontainers.image.description=A timoni.sh module for deploying Cert-Manager.' \
		-a 'org.opencontainers.image.documentation=https://github.com/$(ORG)/$(REPO)/blob/main/README.md'

.PHONY: push-manifests
push-manifests: ## Build and push the Cert-Manager manifests to GHCR
	@timoni -n $(NAMESPACE) build $(NAME) ./modules/cert-manager | flux push artifact \
		oci://ghcr.io/$(ORG)/manifests/cert-manager:$(VERSION) \
		--source=https://github.com/cert-manager/cert-manager \
		--revision=$(VERSION) \
		-f-

.PHONY: import-crds
import-crds: ## Update Cert-Manager API CUE definitions
	@cd modules/cert-manager/templates
	@curl -OLJ https://github.com/cert-manager/cert-manager/releases/download/v$(CERT_MANAGER_VERSION)/cert-manager.crds.yaml
	@yq --yaml-output 'del(.metadata.labels["app.kubernetes.io/name"], .metadata.labels["app.kubernetes.io/instance"], .metadata.labels["app.kubernetes.io/version"])' cert-manager.crds.yaml > crds.yaml
	@cue import -f -o crds.cue -l 'strings.ToLower(kind)' -l 'metadata.name' -p templates crds.yaml
	@rm *crds.yaml
