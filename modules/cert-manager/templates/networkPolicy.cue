package templates

import (
	networkingv1 "k8s.io/api/networking/v1"
)

#NetworkPolicy: networkingv1.#NetworkPolicy & {
	_config:    #Config
	apiVersion: "v1"
	kind:       "NetworkPolicy"
	metadata:   _config.metadata
}
