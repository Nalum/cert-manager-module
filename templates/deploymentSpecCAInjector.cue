package templates

import (
	appsv1 "k8s.io/api/apps/v1"
	corev1 "k8s.io/api/core/v1"
	timoniv1 "timoni.sh/core/v1alpha1"

	cfg "timoni.sh/cert-manager/templates/config"
)

#CAInjectorDeploymentSpec: appsv1.#DeploymentSpec & {
	#main_config:     cfg.#Config
	#deployment_meta: timoniv1.#MetaComponent

	selector: matchLabels: #deployment_meta.#LabelSelector

	template: corev1.#PodTemplateSpec & {

		spec: corev1.#PodSpec & {

			containers: [...corev1.#Container] & [
				{
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

					if #main_config.caInjector.volumeMounts != _|_ {
						volumeMounts: #main_config.caInjector.volumeMounts
					}
				},
			]

			if #main_config.caInjector.volumes != _|_ {
				volumes: #main_config.caInjector.volumes
			}
		}
	}
}
