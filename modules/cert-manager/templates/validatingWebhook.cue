package templates

import (
	admissionregistrationv1 "k8s.io/api/admissionregistration/v1"
	timoniv1 "timoni.sh/core/v1alpha1"
)

#ValidatingWebhook: admissionregistrationv1.#ValidatingWebhookConfiguration & {
	_config: #Config

	_meta: timoniv1.#MetaComponent & {
		#Meta:      _config.metadata
		#Component: "webhook"
	}

	apiVersion: "admissionregistration.k8s.io/v1"
	kind:       "ValidatingWebhookConfiguration"
	metadata:   _meta
	metadata: annotations: "cert-manager.io/inject-ca-from-secret": "\(_meta.namespace)/\(_meta.name)-ca"

	webhooks: [{
		name: "webhook.cert-manager.io"
		namespaceSelector: {
			matchExpressions: [{
				key:      "cert-manager.io/disable-validation"
				operator: "NotIn"
				values: [
					"true",
				]
			}]
		}
		rules: [{
			apiGroups: [
				"cert-manager.io",
				"acme.cert-manager.io",
			]
			apiVersions: [
				"v1",
			]
			operations: [
				"CREATE",
				"UPDATE",
			]
			resources: [
				"*/*",
			]
		}]
		admissionReviewVersions: ["v1"]
		// This webhook only accepts v1 cert-manager resources.
		// Equivalent matchPolicy ensures that non-v1 resource requests are sent to
		// this webhook (after the resources have been converted to v1).
		matchPolicy:    "Equivalent"
		timeoutSeconds: _config.webhook.timeoutSeconds
		failurePolicy:  "Fail"
		sideEffects:    "None"
		clientConfig: {
			if _config.webhook.url.host != _|_ {
				url: "https://\(_config.webhook.url.host)/validate"
			}
			if _config.webhook.url.host == _|_ {
				service: {
					name:      _meta.name
					namespace: _meta.namespace
					path:      "/validate"
				}
			}
		}
	}]
}
