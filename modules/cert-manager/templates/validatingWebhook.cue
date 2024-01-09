package templates

import (
	admissionregistrationv1 "k8s.io/api/admissionregistration/v1"
	timoniv1 "timoni.sh/core/v1alpha1"

	cfg "timoni.sh/cert-manager/templates/config"
)

#ValidatingWebhook: admissionregistrationv1.#ValidatingWebhookConfiguration & {
	#config: cfg.#Config

	#meta: timoniv1.#MetaClusterComponent & {
		#Meta:      #config.metadata
		#Component: "webhook"
	}

	apiVersion: "admissionregistration.k8s.io/v1"
	kind:       "ValidatingWebhookConfiguration"
	metadata:   #meta
	metadata: annotations: "cert-manager.io/inject-ca-from-secret": "\(#config.metadata.namespace)/\(#meta.name)-ca"

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
		timeoutSeconds: #config.webhook.timeoutSeconds
		failurePolicy:  "Fail"
		sideEffects:    "None"
		clientConfig: {
			if #config.webhook.url.host != _|_ {
				url: "https://\(#config.webhook.url.host)/validate"
			}
			if #config.webhook.url.host == _|_ {
				service: {
					name:      #meta.name
					namespace: #config.metadata.namespace
					path:      "/validate"
				}
			}
		}
	}]
}
