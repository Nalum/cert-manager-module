package templates

import (
	appsv1 "k8s.io/api/apps/v1"
	timoniv1 "timoni.sh/core/v1alpha1"
)

#Deployment: appsv1.#Deployment & {
	#config:      #Config
	#component:   string
	#strategy?:   appsv1.#DeploymentStrategy
	#prometheus?: #Prometheus

	#meta: timoniv1.#MetaComponent & {
		#Meta:      #config.metadata
		#Component: #component
	}

	apiVersion: "apps/v1"
	kind:       "Deployment"
	metadata:   #meta

	if #component == "controller" {
		if #config.controller.deploymentLabels != _|_ {
			metadata: labels: #config.controller.deploymentLabels
		}

		if #config.controller.deploymentAnnotations != _|_ {
			metadata: annotations: #config.controller.deploymentAnnotations
		}

		spec: #ControllerDeploymentSpec & {
			#main_config:           #config
			#deployment_meta:       #meta
			#deployment_strategy:   #strategy
			#deployment_prometheus: #prometheus
		}
	}

	if #component == "webhook" {
		if #config.webhook.deploymentLabels != _|_ {
			metadata: labels: #config.webhook.deploymentLabels
		}

		if #config.webhook.deploymentAnnotations != _|_ {
			metadata: annotations: #config.webhook.deploymentAnnotations
		}

		spec: #WebhookDeploymentSpec & {
			#main_config:         #config
			#deployment_meta:     #meta
			#deployment_strategy: #strategy
		}
	}

	if #component == "cainjector" {
		if #config.caInjector.deploymentLabels != _|_ {
			metadata: labels: #config.caInjector.deploymentLabels
		}

		if #config.caInjector.deploymentAnnotations != _|_ {
			metadata: annotations: #config.caInjector.deploymentAnnotations
		}

		spec: #CAInjectorDeploymentSpec & {
			#main_config:         #config
			#deployment_meta:     #meta
			#deployment_strategy: #strategy
		}
	}
}
