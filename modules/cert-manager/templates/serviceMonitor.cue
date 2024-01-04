package templates

import (
	appsv1 "k8s.io/api/apps/v1"
)

#ServiceMonitor: appsv1.#Deployment & {
	#config:    #Config
	apiVersion: "v1"
	kind:       "ServiceMonitor"
	metadata:   #config.metadata
}
