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
	image!:              timoniv1.#Image
	livenessProbe:       corev1.#Probe
	nodeSelector:        timoniv1.#Labels & {"kubernetes.io/os": "linux"}
	podAnnotations?:     timoniv1.#Annotations
	podDisruptionBudget: #PodDisruptionBudgetData
	podLabels?:          timoniv1.#Labels
	proxy?:              #Proxy
	readinessProbe:      corev1.#Probe
	replicas:            *1 | int32

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
	tolerations?: [...corev1.#Toleration]
	topologySpreadConstraints?: [...corev1.#TopologySpreadConstraint]
	volumeMounts?: [...corev1.#VolumeMount]
	volumes?: [...corev1.#Volume]
}
