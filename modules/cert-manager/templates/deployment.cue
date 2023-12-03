package templates

import (
	appsv1 "k8s.io/api/apps/v1"
)

#Deployment: appsv1.#Deployment & {
	_config:    #Config
	apiVersion: "apps/v1"
	kind:       "Deployment"
	metadata:   _config.metadata
	spec:       appsv1.#DeploymentSpec & {
		replicas: _config.replicaCount
		selector: _config.selector

		if _config.strategy != _|_ {
			strategy: _config.strategy
		}

		template: {
			metadata: labels: _config.metadata.labels

			if _config.metadata.annotations != _|_ {
				metadata: annotations: _config.metadata.annotations
			}

			if _config.prometheus != _|_ {
				metadata: annotations: "prometheus.io/path":   "/metrics"
				metadata: annotations: "prometheus.io/scrape": "true"
				metadata: annotations: "prometheus.io/port":   "9402"
			}

			spec: {
				if _config.serviceAccount != _|_ {
					serviceAccountName: _config.serviceAccount.name
				}
			}
		}
	}
}
