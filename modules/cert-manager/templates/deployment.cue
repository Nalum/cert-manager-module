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
		spec: #ControllerDeploymentSpec & {
			_main_config:           _config
			_deployment_meta:       _meta
			_deployment_strategy:   _strategy
			_deployment_prometheus: _prometheus
		}
	}

	if _component == "webhook" {
		spec: #WebhookDeploymentSpec & {
			_main_config:           _config
			_deployment_meta:       _meta
			_deployment_strategy:   _strategy
			_deployment_prometheus: _prometheus
		}
	}

	if _component == "cainjector" {
		spec: #CAInjectorDeploymentSpec & {
			_main_config:           _config
			_deployment_meta:       _meta
			_deployment_strategy:   _strategy
			_deployment_prometheus: _prometheus
		}
	}
}
