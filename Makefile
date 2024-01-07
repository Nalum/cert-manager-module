# Cert-Manager Distribution

.ONESHELL:
.SHELLFLAGS += -e

ORG:="nalum"
REPO:="cert-manager-bundle"
CERT_MANAGER_VERSION:=1.13.2
MV:=1.13.2
KV:=1.29.0
NAME:="cert-manager"
NAMESPACE:="cert-manager"

.PHONY: help
help:  ## Display this help menu
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

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
	@timoni -n $(NAMESPACE) build $(NAME) ./modules/cert-manager -f ./modules/cert-manager/debug_values.cue > all.yaml
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
	@yq --yaml-output '. | select(.kind == "Role")' all.yaml > output/Role.yaml
	@yq --yaml-output '. | select(.kind == "RoleBinding")' all.yaml > output/RoleBinding.yaml
	@yq --yaml-output '. | select(.kind == "Service")' all.yaml > output/Service.yaml
	@yq --yaml-output '. | select(.kind == "ServiceAccount")' all.yaml > output/ServiceAccount.yaml
	@yq --yaml-output '. | select(.kind == "ServiceMonitor")' all.yaml > output/ServiceMonitor.yaml
	@yq --yaml-output '. | select(.kind == "ValidatingWebhookConfiguration")' all.yaml > output/ValidatingWebhookConfiguration.yaml
	@rm all.yaml

.PHONY: gen-files
gen-files: ## Generate resources and write to files
	@mkdir -p output
	@timoni -n $(NAMESPACE) build $(NAME) ./modules/cert-manager > all.yaml
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
	@yq --yaml-output '. | select(.kind == "Role")' all.yaml > output/Role.yaml
	@yq --yaml-output '. | select(.kind == "RoleBinding")' all.yaml > output/RoleBinding.yaml
	@yq --yaml-output '. | select(.kind == "Service")' all.yaml > output/Service.yaml
	@yq --yaml-output '. | select(.kind == "ServiceAccount")' all.yaml > output/ServiceAccount.yaml
	@yq --yaml-output '. | select(.kind == "ServiceMonitor")' all.yaml > output/ServiceMonitor.yaml
	@yq --yaml-output '. | select(.kind == "ValidatingWebhookConfiguration")' all.yaml > output/ValidatingWebhookConfiguration.yaml
	@rm all.yaml

.PHONY: import-crds
import-crds: ## Update Cert-Manager API CUE definitions
	@cd modules/cert-manager/templates
	@curl -OLJ https://github.com/cert-manager/cert-manager/releases/download/v$(CERT_MANAGER_VERSION)/cert-manager.crds.yaml
	@yq --yaml-output 'del(.metadata.labels["app.kubernetes.io/name"], .metadata.labels["app.kubernetes.io/instance"], .metadata.labels["app.kubernetes.io/version"])' cert-manager.crds.yaml > crds.yaml
	@cue import -f -o crds.cue -l 'strings.ToLower(kind)' -l 'metadata.name' -p templates crds.yaml
	@rm *crds.yaml
