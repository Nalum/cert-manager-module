package templates

import (
	admissionregistrationv1 "k8s.io/api/admissionregistration/v1"
)

#ValidatingWebhook: admissionregistrationv1.#ValidatingWebhookConfiguration & {
	_config:    #Config
	apiVersion: "admissionregistration.k8s.io/v1"
	kind:       "ValidatingWebhookConfiguration"
	metadata:   _config.metadata
}
