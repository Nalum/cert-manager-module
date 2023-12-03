package templates

import (
	appsv1 "k8s.io/api/apps/v1"
)

#PodMonitor: appsv1.#Deployment & {
	_config:    #Config
	apiVersion: "v1"
	kind:       "PodMonitor"
	metadata:   _config.metadata
}
