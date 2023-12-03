package templates

import (
	appsv1 "k8s.io/api/apps/v1"
)

#Deployment: appsv1.#Deployment & {
	_config:    #Config
	apiVersion: "v1"
	kind:       "Deployment"
	metadata:   _config.metadata
}
