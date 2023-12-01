# Cert-Manager Distribution

.ONESHELL:
.SHELLFLAGS += -e

VERSION:=$(shell grep 'version:' modules/cert-manager/values.cue | awk '{ print $$2}' | tr -d '"')
ORG:="nalum"
REPO:="cert-manager-bundle"
CERT_MANAGER_VERSION:=1.13.2
MV:=0.1.0
KV:=1.28.0
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
	@cue cmd -t name=$(NAME) -t namespace=$(NAMESPACE) -t mv=$(MV) -t kv=$(KV) build

.PHONY: ls
ls: ## List the CUE generated objects
	@cd modules/cert-manager
	@cue cmd -t name=$(NAME) -t namespace=$(NAMESPACE) -t mv=$(MV) -t kv=$(KV) ls

.PHONY: gen-deploy
gen-deploy: ## Print the Flux deployment
	@timoni -n $(NAMESPACE) build $(NAME) ./modules/cert-manager/ -f ./modules/cert-manager/debug_values.cue | yq e '. | select(.kind == "Deployment")'

.PHONY: push-mod
push-mod: ## Push the Timoni modules to GHCR
	@timoni mod push ./modules/cert-manager oci://ghcr.io/$(ORG)/modules/$(NAME) -v=$(VERSION:v%=%) --latest \
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
	@curl -LJ -o crds.yaml https://github.com/cert-manager/cert-manager/releases/download/v$(CERT_MANAGER_VERSION)/cert-manager.crds.yaml
	@cue import -f -o crds.cue -l 'strings.ToLower(kind)' -l 'metadata.name' -p templates crds.yaml
	@rm crds.yaml
