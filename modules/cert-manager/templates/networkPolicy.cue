package templates

import (
	networkingv1 "k8s.io/api/networking/v1"
)

#NetworkPolicy: networkingv1.#NetworkPolicy & {
	#config:    #Config
	apiVersion: "v1"
	kind:       "NetworkPolicy"
	metadata:   #config.metadata
}
