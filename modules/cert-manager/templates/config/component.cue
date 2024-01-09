package config

import (
	appsv1 "k8s.io/api/apps/v1"
	corev1 "k8s.io/api/core/v1"
	timoniv1 "timoni.sh/core/v1alpha1"
)

#Component: {
	affinity?:                    corev1.#Affinity
	automountServiceAccountToken: *false | bool
	containerSecurityContext:     #ContainerSecurityContext
	deploymentAnnotations?:       timoniv1.#Annotations
	deploymentLabels?:            timoniv1.#Labels
	enableServiceLinks:           *false | bool
	extraArgs?: [...string]
	extraEnvs?: [...corev1.#EnvVar]
	image!:        timoniv1.#Image
	livenessProbe: corev1.#Probe
	nodeSelector:  timoniv1.#Labels
	nodeSelector: "kubernetes.io/os":                            "linux"
	nodeSelector: "node-restriction.kubernetes.io/reserved-for": "platform"
	podAnnotations?:     timoniv1.#Annotations
	podDisruptionBudget: #PodDisruptionBudgetData
	podLabels?:          timoniv1.#Labels
	proxy?:              #Proxy
	readinessProbe:      corev1.#Probe

	resources?: timoniv1.#ResourceRequirements & {
		requests?: timoniv1.#ResourceRequirement & {
			cpu:    *"10m" | timoniv1.#CPUQuantity
			memory: *"32Mi" | timoniv1.#MemoryQuantity
		}
	}

	securityContext: #SecurityContext
	serviceAccount: {
		annotations?:                 timoniv1.#Annotations
		labels?:                      timoniv1.#Labels
		automountServiceAccountToken: *false | bool
	}

	service: {
		annotations?: timoniv1.#Annotations
		labels?:      timoniv1.#Labels
		type:         *corev1.#ServiceTypeClusterIP | corev1.#enumServiceType
	}

	strategy?: appsv1.#DeploymentStrategy
	tolerations?: [...corev1.#Toleration] | [
		{
			key:      "node-restriction.kubernetes.io/reserved-for"
			operator: "Equal"
			value:    "platform"
		},
	]
	topologySpreadConstraints?: [...corev1.#TopologySpreadConstraint]

	volumeMounts: [...corev1.#VolumeMount] | *[{
		mountPath: "/var/run/secrets/kubernetes.io/serviceaccount"
		name:      "serviceaccount-token"
		readOnly:  true
	}]

	volumes: [...corev1.#Volume] | *[{
		name: "serviceaccount-token"
		projected: {
			defaultMode: 444
			sources: [{
				serviceAccountToken: {
					expirationSeconds: 3607
					path:              "token"
				}
			}, {
				configMap: {
					name: "kube-root-ca.crt"
					items: [{
						key:  "ca.crt"
						path: "ca.crt"
					}]
				}
			}, {
				downwardAPI: {
					items: [{
						path: "namespace"
						fieldRef: {
							apiVersion: "v1"
							fieldPath:  "metadata.namespace"
						}
					}]
				}
			}]
		}
	}]
}
