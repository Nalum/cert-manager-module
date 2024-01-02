package templates

import (
	appsv1 "k8s.io/api/apps/v1"
	corev1 "k8s.io/api/core/v1"
	timoniv1 "timoni.sh/core/v1alpha1"
)

#CAInjectorDeploymentSpec: appsv1.#DeploymentSpec & {
	_main_config:            #Config
	_deployment_meta:        timoniv1.#MetaComponent
	_deployment_strategy?:   appsv1.#DeploymentStrategy
	_deployment_prometheus?: #Prometheus

	replicas: _main_config.caInjector.replicas
	selector: matchLabels: _deployment_meta.#LabelSelector

	if _deployment_strategy != _|_ {
		strategy: _deployment_strategy
	}
	template: corev1.#PodTemplateSpec & {
		metadata: labels: _deployment_meta.labels

		if _main_config.caInjector.podLabels != _|_ {
			metadata: labels: _main_config.caInjector.podLabels
		}

		if _main_config.caInjector.podAnnotations != _|_ {
			metadata: annotations: _main_config.caInjector.podAnnotations
		}

		spec: corev1.#PodSpec & {
			if _main_config.caInjector.serviceAccount != _|_ {
				serviceAccountName: _main_config.caInjector.serviceAccount.name
			}

			if _main_config.caInjector.serviceAccount == _|_ {
				serviceAccountName: _deployment_meta.name
			}

			if _main_config.caInjector.automountServiceAccountToken != _|_ {
				automountServiceAccountToken: _main_config.caInjector.automountServiceAccountToken
			}

			if _main_config.caInjector.enableServiceLinks != _|_ {
				enableServiceLinks: _main_config.caInjector.enableServiceLinks
			}

			if _main_config.priorityClass != _|_ {
				priorityClassName: _main_config.priorityClass
			}

			if _main_config.caInjector.securityContext != _|_ {
				securityContext: _main_config.caInjector.securityContext
			}

			containers: [...corev1.#Container] & [
					{
					name:            _deployment_meta.name
					image:           _main_config.caInjector.image.reference
					imagePullPolicy: _main_config.caInjector.imagePullPolicy

					args: [
						"--v=\(_main_config.logLevel)",
						"--leader-election-namespace=\(_main_config.leaderElection.namespace)",

						if _main_config.leaderElection.leaseDuration != _|_ {
							"--leader-election-lease-duration=\(_main_config.leaderElection.leaseDuration)"
						},

						if _main_config.leaderElection.renewDeadline != _|_ {
							"--leader-election-renew-deadline=\(_main_config.leaderElection.renewDeadline)"
						},

						if _main_config.leaderElection.retryPeriod != _|_ {
							"--leader-election-retry-period=\(_main_config.leaderElection.retryPeriod)"
						},

						if _main_config.caInjector.extraArgs != _|_ {
							for a in _main_config.caInjector.extraArgs {a}
						},
					]

					env: [
						{
							name: "POD_NAMESPACE"
							valueFrom: fieldRef: fieldPath: "metadata.namespace"
						},

						if _main_config.caInjector.extraEnvs != _|_ {
							for e in _main_config.caInjector.extraEnvs {e}
						},
					]

					if _main_config.caInjector.containerSecurityContext != _|_ {
						securityContext: _main_config.caInjector.containerSecurityContext
					}

					if _main_config.caInjector.resources != _|_ {
						resources: _main_config.caInjector.resources
					}

					if _main_config.caInjector.volumeMounts != _|_ {
						volumeMounts: _main_config.caInjector.volumeMounts
					}
				},
			]

			if _main_config.caInjector.nodeSelector != _|_ {
				nodeSelector: _main_config.caInjector.nodeSelector
			}

			if _main_config.caInjector.affinity != _|_ {
				affinity: _main_config.caInjector.affinity
			}

			if _main_config.caInjector.tolerations != _|_ {
				tolerations: _main_config.caInjector.tolerations
			}

			if _main_config.caInjector.topologySpreadConstraints != _|_ {
				topologySpreadConstraints: _main_config.caInjector.topologySpreadConstraints
			}

			if _main_config.caInjector.volumes != _|_ {
				volumes: _main_config.caInjector.volumes
			}
		}
	}
}
