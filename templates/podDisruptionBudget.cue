package templates

import (
	"strings"
	policyv1 "k8s.io/api/policy/v1"
	timoniv1 "timoni.sh/core/v1alpha1"
	cfg "timoni.sh/cert-manager/templates/config"
)

#PodDisruptionBudget: policyv1.#PodDisruptionBudget & {
	#config:    cfg.#Config
	#component: string

	#meta: timoniv1.#MetaComponent & {
		#Meta:      #config.metadata
		#Component: strings.ToLower(#component)
	}

	apiVersion: "policy/v1"
	kind:       "PodDisruptionBudget"
	metadata:   #meta

	spec: {
		selector: matchLabels: #meta.#LabelSelector
		if #config.highAvailability.enabled &&
			#config[#component].podDisruptionBudget.minAvailable == _|_ &&
			#config[#component].podDisruptionBudget.maxUnavailable == _|_ {
			minAvailable: #config[#component].replicas - 1
		}
		if #config[#component].podDisruptionBudget.minAvailable != _|_ {
			minAvailable: #config[#component].podDisruptionBudget.minAvailable & {uint16 & <=#config[#component].replicas | cfg.#Percent}
		}
		if #config[#component].podDisruptionBudget.maxUnavailable != _|_ {
			maxUnavailable: #config[#component].podDisruptionBudget.maxUnavailable
		}
	}
}
