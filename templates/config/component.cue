package config

import (
	appsv1 "k8s.io/api/apps/v1"
	corev1 "k8s.io/api/core/v1"
	timoniv1 "timoni.sh/core/v1alpha1"
)

#Component: {
	// group of affinity scheduling rules.
	affinity?: corev1.#Affinity
	// indicates whether a service account token should be automatically mounted.
	automountServiceAccountToken: *false | bool
	// is the security context for the container.
	containerSecurityContext: #ContainerSecurityContext
	// is the annotations for the deployment.
	deploymentAnnotations?: timoniv1.#Annotations
	// is the labels for the deployment.
	deploymentLabels?: timoniv1.#Labels
	// indicates whether information about services should be injected into pod's environment variables, matching the syntax of Docker links.
	enableServiceLinks: *false | bool
	// Additional command line flags to pass to cert-manager binaries.
	// To see all available flags run docker run quay.io/jetstack/cert-manager-<component>:<version> --help
	extraArgs?: [...string]
	// is a list of additional environment variables to pass to the container.
	extraEnvs?: [...corev1.#EnvVar]
	// is the container image to use.
	image!: timoniv1.#Image
	// is the liveness probe.
	livenessProbe: corev1.#Probe
	// is a selector which must be true for the pod to fit on a node.
	nodeSelector: timoniv1.#Labels
	nodeSelector: "kubernetes.io/os": "linux"
	// is the annotations for the pod.
	podAnnotations?: timoniv1.#Annotations
	// is the pod disruption budget.
	podDisruptionBudget: #PodDisruptionBudgetData
	// is the labels for the pod.
	podLabels?: timoniv1.#Labels
	// defines the proxy configuration to be used by the container.
	proxy?: #Proxy
	// is the readiness probe.
	readinessProbe: corev1.#Probe
	// is the number of desired replicas.
	replicas: *1 | uint16 & >0

	// is the resource requirements for the container.
	resources?: timoniv1.#ResourceRequirements & {
		requests?: timoniv1.#ResourceRequirement & {
			cpu:    *"10m" | timoniv1.#CPUQuantity
			memory: *"32Mi" | timoniv1.#MemoryQuantity
		}
	}

	// is the security context for the container.
	securityContext: #SecurityContext
	serviceAccount: {
		// is the annotations for the service account.
		annotations?: timoniv1.#Annotations
		// is the labels for the service account.
		labels?: timoniv1.#Labels
		// indicates whether a service account token should be automatically mounted.
		automountServiceAccountToken: *false | bool
	}

	service: {
		// is the annotations for the service.
		annotations?: timoniv1.#Annotations
		// is the labels for the service.
		labels?: timoniv1.#Labels
		// is the type of the service.
		type: *corev1.#ServiceTypeClusterIP | corev1.#enumServiceType
	}

	// is the deployment strategy to use to replace existing pods with new ones.
	strategy?: appsv1.#DeploymentStrategy
	// is the tolerations for the pod.
	tolerations?: [...corev1.#Toleration]
	// is the topology spread constraints for the pod.
	topologySpreadConstraints?: [...corev1.#TopologySpreadConstraint]

	// is the volume mounts for the container.
	volumeMounts: [...corev1.#VolumeMount] | *[{
		mountPath: "/var/run/secrets/kubernetes.io/serviceaccount"
		name:      "serviceaccount-token"
		readOnly:  true
	}]

	// is the volumes for the pod.
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
