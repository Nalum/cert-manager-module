package templates

import (
	corev1 "k8s.io/api/core/v1"
	timoniv1 "timoni.sh/core/v1alpha1"
)

#ServiceAccount: corev1.#ServiceAccount & {
	#config:    #Config
	#component: string

	#meta: timoniv1.#MetaComponent & {
		#Meta:      #config.metadata
		#Component: #component
	}

	apiVersion: "v1"
	kind:       "ServiceAccount"
	metadata:   #meta

	if #config.imagePullSecrets != _|_ {
		imagePullSecrets: #config.imagePullSecrets
	}

	if #component == "controller" {
		if #config.controller.serviceAccount.labels != _|_ {
			metadata: labels: #config.controller.serviceAccount.labels
		}

		if #config.controller.serviceAccount.annotations != _|_ {
			metadata: annotations: #config.controller.serviceAccount.annotations
		}

		automountServiceAccountToken: #config.controller.serviceAccount.automountServiceAccountToken
	}

	if #component == "webhook" {
		if #config.webhook.serviceAccount.labels != _|_ {
			metadata: labels: #config.webhook.serviceAccount.labels
		}

		if #config.webhook.serviceAccount.annotations != _|_ {
			metadata: annotations: #config.webhook.serviceAccount.annotations
		}

		automountServiceAccountToken: #config.webhook.serviceAccount.automountServiceAccountToken
	}

	if #component == "cainjector" {
		if #config.caInjector.serviceAccount.labels != _|_ {
			metadata: labels: #config.caInjector.serviceAccount.labels
		}

		if #config.caInjector.serviceAccount.annotations != _|_ {
			metadata: annotations: #config.caInjector.serviceAccount.annotations
		}

		automountServiceAccountToken: #config.caInjector.serviceAccount.automountServiceAccountToken
	}

	if #component == "startupapicheck" {
		if #config.test.startupAPICheck.serviceAccount.labels != _|_ {
			metadata: labels: #config.test.startupAPICheck.serviceAccount.labels
		}

		if #config.test.startupAPICheck.serviceAccount.annotations != _|_ {
			metadata: annotations: #config.test.startupAPICheck.serviceAccount.annotations
		}

		automountServiceAccountToken: #config.test.startupAPICheck.serviceAccount.automountServiceAccountToken
	}
}
