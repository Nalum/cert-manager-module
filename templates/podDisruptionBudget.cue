package templates

import (
	policyv1 "k8s.io/api/policy/v1"
	timoniv1 "timoni.sh/core/v1alpha1"

	cfg "timoni.sh/cert-manager/templates/config"
)

#PodDisruptionBudget: policyv1.#PodDisruptionBudget & {
	#config:    cfg.#Config
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
				if #config.controller.podDisruptionBudget.minAvailable != _|_ {
					minAvailable: #config.controller.podDisruptionBudget.minAvailable
				}
				if #config.controller.podDisruptionBudget.maxUnavailable != _|_ {
					maxUnavailable: #config.controller.podDisruptionBudget.maxUnavailable
				}
			}
		}

		if #component == "webhook" {
			if #config.webhook.podDisruptionBudget != _|_ {
				if #config.webhook.podDisruptionBudget.minAvailable != _|_ {
					minAvailable: #config.webhook.podDisruptionBudget.minAvailable
				}
				if #config.webhook.podDisruptionBudget.maxUnavailable != _|_ {
					maxUnavailable: #config.webhook.podDisruptionBudget.maxUnavailable
				}
			}
		}

		if #component == "cainjector" {
			if #config.caInjector.podDisruptionBudget != _|_ {
				if #config.caInjector.podDisruptionBudget.minAvailable != _|_ {
					minAvailable: #config.caInjector.podDisruptionBudget.minAvailable
				}
				if #config.caInjector.podDisruptionBudget.maxUnavailable != _|_ {
					maxUnavailable: #config.caInjector.podDisruptionBudget.maxUnavailable
				}
			}
		}
	}
}
