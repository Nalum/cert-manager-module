package templates

import (
	"strings"
	appsv1 "k8s.io/api/apps/v1"
	corev1 "k8s.io/api/core/v1"
	timoniv1 "timoni.sh/core/v1alpha1"

	cfg "timoni.sh/cert-manager/templates/config"
)

#Deployment: appsv1.#Deployment & {
	#config:    cfg.#Config
	#meta:      timoniv1.#MetaComponent
	#component: string

	if #config[#component].deploymentLabels != _|_ {
		metadata: labels: #config[#component].deploymentLabels
	}

	if #config[#component].deploymentAnnotations != _|_ {
		metadata: annotations: #config[#component].deploymentAnnotations
	}

	apiVersion: "apps/v1"
	kind:       "Deployment"
	metadata:   #meta

	spec: appsv1.#DeploymentSpec & {
		selector: matchLabels: #meta.#LabelSelector

		if #config.highAvailability.enabled {
			replicas: #config.highAvailability[#component+"Replicas"]
		}

		if !#config.highAvailability.enabled {
			replicas: #config[#component].replicas
		}

		if #config[#component].strategy != _|_ {
			strategy: appsv1.#DeploymentStrategy & #config[#component].strategy
		}

		template: corev1.#PodTemplateSpec & {
			metadata: labels: #meta.labels

			if #config[#component].podLabels != _|_ {
				metadata: labels: #config[#component].podLabels
			}

			if #config[#component].podAnnotations != _|_ {
				metadata: annotations: #config[#component].podAnnotations
			}

			spec: corev1.#PodSpec & {
				containers: [...corev1.#Container] & [
					{
						name:            #meta.name
						image:           #config[#component].image.reference
						imagePullPolicy: #config[#component].image.pullPolicy
						securityContext: #config[#component].containerSecurityContext

						if #config[#component].resources != _|_ {
							resources: #config[#component].resources
						}

						env: [
							{
								name: "POD_NAMESPACE"
								valueFrom: fieldRef: fieldPath: "metadata.namespace"
							},

							if #config[#component].extraEnvs != _|_ {
								for e in #config[#component].extraEnvs {e}
							},
						]
					},
				]
				serviceAccountName:           #meta.name
				securityContext:              #config[#component].securityContext
				nodeSelector:                 #config[#component].nodeSelector
				automountServiceAccountToken: #config[#component].automountServiceAccountToken

				if #config[#component].enableServiceLinks {
					enableServiceLinks: #config[#component].enableServiceLinks
				}

				if #config.priorityClassName != _|_ {
					priorityClassName: #config.priorityClassName
				}

				if #config[#component].affinity != _|_ {
					affinity: #config[#component].affinity
				}

				if #config[#component].tolerations != _|_ {
					tolerations: #config[#component].tolerations
				}

				if #config[#component].topologySpreadConstraints != _|_ {
					topologySpreadConstraints: #config[#component].topologySpreadConstraints
				}
			}
		}
	}
}

#ControllerDeployment: #Deployment & {
	#config:    cfg.#Config
	#component: "controller"

	#meta: timoniv1.#MetaComponent & {
		#Meta:      #config.metadata
		#Component: strings.ToLower(#component)
	}

	spec: #ControllerDeploymentSpec & {
		#main_config:            #config
		#deployment_meta:        #meta
		#deployment_monitoring?: #config.controller.monitoring
	}
}

#WebhookDeployment: #Deployment & {
	#config:    cfg.#Config
	#component: "webhook"

	#meta: timoniv1.#MetaComponent & {
		#Meta:      #config.metadata
		#Component: strings.ToLower(#component)
	}

	spec: #WebhookDeploymentSpec & {
		#main_config:     #config
		#deployment_meta: #meta
	}
}

#CaInjectorrDeployment: #Deployment & {
	#config:    cfg.#Config
	#component: "caInjector"

	#meta: timoniv1.#MetaComponent & {
		#Meta:      #config.metadata
		#Component: strings.ToLower(#component)
	}

	spec: #CAInjectorDeploymentSpec & {
		#main_config:     #config
		#deployment_meta: #meta
	}
}
