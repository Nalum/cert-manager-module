package templates

import (
	appsv1 "k8s.io/api/apps/v1"
)

#PodSecurityPolicy: appsv1.#Deployment & {
	_config:    #Config
	apiVersion: "v1"
	kind:       "PodSecurityPolicy"
	metadata:   _config.metadata
}