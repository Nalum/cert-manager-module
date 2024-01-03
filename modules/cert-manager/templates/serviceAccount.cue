package templates

import (
	corev1 "k8s.io/api/core/v1"
	timoniv1 "timoni.sh/core/v1alpha1"
)

#ServiceAccount: corev1.#ServiceAccount & {
	_config:    #Config
	_component: string

	_meta: timoniv1.#MetaComponent & {
		#Meta:      _config.metadata
		#Component: _component
	}

	apiVersion: "v1"
	kind:       "ServiceAccount"
	metadata:   _meta

	if _config.imagePullSecrets != _|_ {
		imagePullSecrets: _config.imagePullSecrets
	}

	if _component == "controller" {
		if _config.controller.serviceAccount.labels != _|_ {
			metadata: labels: _config.controller.serviceAccount.labels
		}

		if _config.controller.serviceAccount.annotations != _|_ {
			metadata: annotations: _config.controller.serviceAccount.annotations
		}

		automountServiceAccountToken: _config.controller.serviceAccount.automountServiceAccountToken
	}

	if _component == "webhook" {
		if _config.webhook.serviceAccount.labels != _|_ {
			metadata: labels: _config.webhook.serviceAccount.labels
		}

		if _config.webhook.serviceAccount.annotations != _|_ {
			metadata: annotations: _config.webhook.serviceAccount.annotations
		}

		automountServiceAccountToken: _config.webhook.serviceAccount.automountServiceAccountToken
	}

	if _component == "cainjector" {
		if _config.caInjector.serviceAccount.labels != _|_ {
			metadata: labels: _config.caInjector.serviceAccount.labels
		}

		if _config.caInjector.serviceAccount.annotations != _|_ {
			metadata: annotations: _config.caInjector.serviceAccount.annotations
		}

		automountServiceAccountToken: _config.caInjector.serviceAccount.automountServiceAccountToken
	}

	if _component == "startupapicheck" {
		if _config.startupAPICheck.serviceAccount.labels != _|_ {
			metadata: labels: _config.startupAPICheck.serviceAccount.labels
		}

		if _config.startupAPICheck.serviceAccount.annotations != _|_ {
			metadata: annotations: _config.startupAPICheck.serviceAccount.annotations
		}

		automountServiceAccountToken: _config.startupAPICheck.serviceAccount.automountServiceAccountToken
	}
}
