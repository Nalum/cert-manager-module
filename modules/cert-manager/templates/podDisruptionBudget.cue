package templates

import (
	policyv1 "k8s.io/api/policy/v1"
	timoniv1 "timoni.sh/core/v1alpha1"
)

#PodDisruptionBudget: policyv1.#PodDisruptionBudget & {
	#config:    #Config
	#component: string

	#meta: timoniv1.#MetaComponent & {
		#Meta:      #config.metadata
		#Component: #component
	}

	apiVersion: "policy/v1"
	kind:       "PodDisruptionBudget"
	metadata:   #meta

	spec: {
		selector: matchLabels: #meta.#LabelSelector

		if #component == "controller" {

			if #config.controller.podDisruptionBudget != _|_ {
				minAvailable:   #config.controller.podDisruptionBudget.minAvailable
				maxUnavailable: #config.controller.podDisruptionBudget.maxUnavailable
			}
		}

		if #component == "webhook" {

			if #config.webhook.podDisruptionBudget != _|_ {
				minAvailable:   #config.webhook.podDisruptionBudget.minAvailable
				maxUnavailable: #config.webhook.podDisruptionBudget.maxUnavailable
			}
		}

		if #component == "cainjector" {

			if #config.caInjector.podDisruptionBudget != _|_ {
				minAvailable:   #config.caInjector.podDisruptionBudget.minAvailable
				maxUnavailable: #config.caInjector.podDisruptionBudget.maxUnavailable
			}
		}
	}
}
