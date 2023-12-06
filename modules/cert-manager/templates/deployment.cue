package templates

import (
	appsv1 "k8s.io/api/apps/v1"
	timoniv1 "timoni.sh/core/v1alpha1"
)

#Deployment: appsv1.#Deployment & {
	_config:    #Config
	_component: string
	_strategy:  appsv1.#DeploymentStrategy
	_prometheus?: {...}

	apiVersion: "apps/v1"
	kind:       "Deployment"

	_metadata: timoniv1.#MetaComponent & {
		#Meta:      _config.metadata
		#Component: _component
	}

	metadata: _metadata

	spec: appsv1.#DeploymentSpec & {
		replicas: _config.replicaCount
		selector: timoniv1.#MatchLabelsComponent & {
			#SelectorLabels: _config.selector.labels
			#Component:      _component
		}

		if _strategy != _|_ {
			strategy: _strategy
		}

		template: {
			metadata: labels: _metadata.labels

			if _metadata.annotations != _|_ {
				metadata: annotations: _metadata.annotations
			}

			if _prometheus != _|_ && _prometheus.serviceMonitor == _|_ {
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
