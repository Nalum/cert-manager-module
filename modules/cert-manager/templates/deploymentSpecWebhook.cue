package templates

import (
	appsv1 "k8s.io/api/apps/v1"
	timoniv1 "timoni.sh/core/v1alpha1"
)

#WebhookDeploymentSpec: appsv1.#DeploymentSpec & {
	_config:      #Config
	_meta:        timoniv1.#MetaComponent
	_strategy:    appsv1.#DeploymentStrategy
	_prometheus?: #Prometheus
}
