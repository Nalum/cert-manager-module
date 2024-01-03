package templates

import (
	appsv1 "k8s.io/api/apps/v1"
	timoniv1 "timoni.sh/core/v1alpha1"
)

#Deployment: appsv1.#Deployment & {
	_config:      #Config
	_component:   string
	_strategy?:   appsv1.#DeploymentStrategy
	_prometheus?: #Prometheus

	_meta: timoniv1.#MetaComponent & {
		#Meta:      _config.metadata
		#Component: _component
	}

	apiVersion: "apps/v1"
	kind:       "Deployment"

	metadata: _meta

	if _component == "controller" {
		if _config.controller.deploymentLabels != _|_ {
			metadata: labels: _config.controller.deploymentLabels
		}

		if _config.controller.deploymentAnnotations != _|_ {
			metadata: annotations: _config.controller.deploymentAnnotations
		}

		spec: #ControllerDeploymentSpec & {
			_main_config:           _config
			_deployment_meta:       _meta
			_deployment_strategy:   _strategy
			_deployment_prometheus: _prometheus
		}
	}

	if _component == "webhook" {
		if _config.webhook.deploymentLabels != _|_ {
			metadata: labels: _config.webhook.deploymentLabels
		}

		if _config.webhook.deploymentAnnotations != _|_ {
			metadata: annotations: _config.webhook.deploymentAnnotations
		}

		spec: #WebhookDeploymentSpec & {
			_main_config:         _config
			_deployment_meta:     _meta
			_deployment_strategy: _strategy
		}
	}

	if _component == "cainjector" {
		if _config.caInjector.deploymentLabels != _|_ {
			metadata: labels: _config.caInjector.deploymentLabels
		}

		if _config.caInjector.deploymentAnnotations != _|_ {
			metadata: annotations: _config.caInjector.deploymentAnnotations
		}

		spec: #CAInjectorDeploymentSpec & {
			_main_config:         _config
			_deployment_meta:     _meta
			_deployment_strategy: _strategy
		}
	}
}
