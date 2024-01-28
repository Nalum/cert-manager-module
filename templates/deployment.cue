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

	#monitoring?: #config[#component].monitoring

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

						if #config[#component].containerSecurityContext != _|_ {
							securityContext: #config[#component].containerSecurityContext
						}

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
					}]
				serviceAccountName: #meta.name
				securityContext:    #config[#component].securityContext

				if #config[#component].automountServiceAccountToken != _|_ {
					automountServiceAccountToken: #config[#component].automountServiceAccountToken
				}

				if #config[#component].enableServiceLinks != _|_ {
					enableServiceLinks: #config[#component].enableServiceLinks
				}

				if #config.priorityClass != _|_ {
					priorityClassName: #config.priorityClass
				}

				if #config[#component].nodeSelector != _|_ {
					nodeSelector: #config[#component].nodeSelector
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

				if #config[#component].podDNSPolicy != _|_ {
					dnsPolicy: #config[#component].podDNSPolicy
				}

				if #config[#component].podDNSConfig != _|_ {
					dnsConfig: #config[#component].podDNSConfig
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
		#config:          #config
		#deployment_meta: #meta
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
		#config:          #config
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
		#config:          #config
		#deployment_meta: #meta
	}
}
