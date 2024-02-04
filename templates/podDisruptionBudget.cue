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
		if #config[#component].podDisruptionBudget.enabled {
			if #config[#component].podDisruptionBudget.minAvailable != _|_ {
				minAvailable: #config[#component].podDisruptionBudget.minAvailable
			}
			if #config[#component].podDisruptionBudget.maxUnavailable != _|_ {
				maxUnavailable: #config[#component].podDisruptionBudget.maxUnavailable
			}
		}
	}
}
