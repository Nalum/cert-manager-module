package templates

import (
	admissionregistrationv1 "k8s.io/api/admissionregistration/v1"
)

#MutatingWebhook: admissionregistrationv1.#MutatingWebhookConfiguration & {
	_config:    #Config
	apiVersion: "admissionregistration.k8s.io/v1"
	kind:       "MutatingWebhookConfiguration"
	metadata:   _config.metadata
}
