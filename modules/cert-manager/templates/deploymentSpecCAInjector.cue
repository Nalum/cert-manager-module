package templates

import (
	appsv1 "k8s.io/api/apps/v1"
	corev1 "k8s.io/api/core/v1"
	timoniv1 "timoni.sh/core/v1alpha1"

	cfg "timoni.sh/cert-manager/templates/config"
)

#CAInjectorDeploymentSpec: appsv1.#DeploymentSpec & {
	#main_config:          cfg.#Config
	#deployment_meta:      timoniv1.#MetaComponent
	#deployment_strategy?: appsv1.#DeploymentStrategy

	replicas: #main_config.caInjector.replicas
	selector: matchLabels: #deployment_meta.#LabelSelector

	if #deployment_strategy != _|_ {
		strategy: #deployment_strategy
	}

	template: corev1.#PodTemplateSpec & {
		metadata: labels: #deployment_meta.labels

		if #main_config.caInjector.podLabels != _|_ {
			metadata: labels: #main_config.caInjector.podLabels
		}

		if #main_config.caInjector.podAnnotations != _|_ {
			metadata: annotations: #main_config.caInjector.podAnnotations
		}

		spec: corev1.#PodSpec & {
			serviceAccountName: #deployment_meta.name

			if #main_config.caInjector.automountServiceAccountToken != _|_ {
				automountServiceAccountToken: #main_config.caInjector.automountServiceAccountToken
			}

			if #main_config.caInjector.enableServiceLinks != _|_ {
				enableServiceLinks: #main_config.caInjector.enableServiceLinks
			}

			if #main_config.priorityClass != _|_ {
				priorityClassName: #main_config.priorityClass
			}

			if #main_config.caInjector.securityContext != _|_ {
				securityContext: #main_config.caInjector.securityContext
			}

			containers: [...corev1.#Container] & [
				{
					name:            #deployment_meta.name
					image:           #main_config.caInjector.image.reference
					imagePullPolicy: #main_config.caInjector.image.pullPolicy

					args: [
						"--v=\(#main_config.logLevel)",
						"--leader-election-namespace=\(#main_config.leaderElection.namespace)",

						if #main_config.leaderElection.leaseDuration != _|_ {
							"--leader-election-lease-duration=\(#main_config.leaderElection.leaseDuration)"
						},

						if #main_config.leaderElection.renewDeadline != _|_ {
							"--leader-election-renew-deadline=\(#main_config.leaderElection.renewDeadline)"
						},

						if #main_config.leaderElection.retryPeriod != _|_ {
							"--leader-election-retry-period=\(#main_config.leaderElection.retryPeriod)"
						},

						if #main_config.caInjector.extraArgs != _|_ {
							for a in #main_config.caInjector.extraArgs {a}
						},
					]

					env: [
						{
							name: "POD_NAMESPACE"
							valueFrom: fieldRef: fieldPath: "metadata.namespace"
						},

						if #main_config.caInjector.extraEnvs != _|_ {
							for e in #main_config.caInjector.extraEnvs {e}
						},
					]

					if #main_config.caInjector.containerSecurityContext != _|_ {
						securityContext: #main_config.caInjector.containerSecurityContext
					}

					if #main_config.caInjector.resources != _|_ {
						resources: #main_config.caInjector.resources
					}

					if #main_config.caInjector.volumeMounts != _|_ {
						volumeMounts: #main_config.caInjector.volumeMounts
					}
				},
			]

			if #main_config.caInjector.nodeSelector != _|_ {
				nodeSelector: #main_config.caInjector.nodeSelector
			}

			if #main_config.caInjector.affinity != _|_ {
				affinity: #main_config.caInjector.affinity
			}

			if #main_config.caInjector.tolerations != _|_ {
				tolerations: #main_config.caInjector.tolerations
			}

			if #main_config.caInjector.topologySpreadConstraints != _|_ {
				topologySpreadConstraints: #main_config.caInjector.topologySpreadConstraints
			}

			if #main_config.caInjector.volumes != _|_ {
				volumes: #main_config.caInjector.volumes
			}
		}
	}
}
