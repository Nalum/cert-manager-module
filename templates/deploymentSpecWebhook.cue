package templates

import (
	appsv1 "k8s.io/api/apps/v1"
	corev1 "k8s.io/api/core/v1"
	timoniv1 "timoni.sh/core/v1alpha1"

	cfg "timoni.sh/cert-manager/templates/config"
)

#WebhookDeploymentSpec: appsv1.#DeploymentSpec & {
	#main_config:          cfg.#Config
	#deployment_meta:      timoniv1.#MetaComponent
	#deployment_strategy?: appsv1.#DeploymentStrategy

	selector: matchLabels: #deployment_meta.#LabelSelector

	if #deployment_strategy != _|_ {
		strategy: #deployment_strategy
	}

	template: corev1.#PodTemplateSpec & {

		spec: corev1.#PodSpec & {

			if #main_config.webhook.hostNetwork != false {
				hostNetwork: true
				dnsPolicy:   "ClusterFirstWithHostNet"
			}

			containers: [...corev1.#Container] & [
				{
					args: [
						"--v=\(#main_config.logLevel)",

						if #main_config.webhook.config != _|_ {
							"--secure-port=\(#main_config.webhook.config.securePort)"
						},

						if #main_config.webhook.config == _|_ {
							"--secure-port=\(#main_config.webhook.securePort)"
						},

						if #main_config.webhook.config != _|_ {
							"--config=/var/cert-manager/config/config.yaml"
						},

						if #main_config.webhook.featureGates != _|_ {
							"--feature-gates=\(#deployment_meta.webhook.featureGates)"
						},

						if #main_config.webhook.config.tlsConfig == _|_ || (#main_config.webhook.config.tlsConfig.dynamic == _|_ && #main_config.webhook.config.tlsConfig.filesystem == _|_) {
							"--dynamic-serving-ca-secret-namespace=$(POD_NAMESPACE)"
						},

						if #main_config.webhook.config.tlsConfig == _|_ || (#main_config.webhook.config.tlsConfig.dynamic == _|_ && #main_config.webhook.config.tlsConfig.filesystem == _|_) {
							"--dynamic-serving-ca-secret-name=\(#deployment_meta.name)-ca"
						},

						if #main_config.webhook.config.tlsConfig == _|_ || (#main_config.webhook.config.tlsConfig.dynamic == _|_ && #main_config.webhook.config.tlsConfig.filesystem == _|_) {
							"--dynamic-serving-dns-names=\(#deployment_meta.name)"
						},

						if #main_config.webhook.config.tlsConfig == _|_ || (#main_config.webhook.config.tlsConfig.dynamic == _|_ && #main_config.webhook.config.tlsConfig.filesystem == _|_) {
							"--dynamic-serving-dns-names=\(#deployment_meta.name).$(POD_NAMESPACE)"
						},

						if #main_config.webhook.config.tlsConfig == _|_ || (#main_config.webhook.config.tlsConfig.dynamic == _|_ && #main_config.webhook.config.tlsConfig.filesystem == _|_) {
							"--dynamic-serving-dns-names=\(#deployment_meta.name).$(POD_NAMESPACE).svc"
						},

						if (#main_config.webhook.config.tlsConfig == _|_ || (#main_config.webhook.config.tlsConfig.dynamic == _|_ && #main_config.webhook.config.tlsConfig.filesystem == _|_)) && #main_config.webhook.url.host != _|_ {
							"--dynamic-serving-dns-names=\(#main_config.webhook.url.host)"
						},

						if #main_config.webhook.extraArgs != _|_ {
							for a in #main_config.webhook.extraArgs {a}
						},
					]

					ports: [
						{
							name:     "https"
							protocol: "TCP"
							if #main_config.webhook.config != _|_ {
								containerPort: #main_config.webhook.config.securePort
							}
							if #main_config.webhook.config == _|_ {
								containerPort: #main_config.webhook.securePort
							}
						},
						{
							name:          "healthcheck"
							protocol:      "TCP"
							containerPort: *6080 | #main_config.webhook.config.healthzPort
						},
					]

					if #main_config.webhook.livenessProbe != _|_ {
						livenessProbe: #main_config.webhook.livenessProbe & {
							httpGet: {
								port:   "healthcheck"
								path:   "/livez"
								scheme: "HTTP"
							}
							initialDelaySeconds: *60 | int
							periodSeconds:       *10 | int
							timeoutSeconds:      *1 | int
							successThreshold:    *1 | int
							failureThreshold:    *3 | int
						}
					}

					if #main_config.webhook.readinessProbe != _|_ {
						readinessProbe: #main_config.webhook.readinessProbe & {
							httpGet: {
								port:   "healthcheck"
								path:   "/healthz"
								scheme: "HTTP"
							}
							initialDelaySeconds: *5 | int
							periodSeconds:       *5 | int
							timeoutSeconds:      *1 | int
							successThreshold:    *1 | int
							failureThreshold:    *3 | int
						}
					}

					if #main_config.webhook.volumeMounts != _|_ || #main_config.webhook.config != _|_ {
						volumeMounts: [
							if #main_config.webhook.config != _|_ {
								{
									name:      "config"
									mountPath: "/var/cert-manager/config"
								}
							},
							if #main_config.webhook.volumeMounts != _|_ {
								for k, v in #main_config.webhook.volumeMounts {v}
							},
						]
					}
				},
			]

			if #main_config.webhook.volumes != _|_ || #main_config.webhook.config != _|_ {
				volumes: [
					if #main_config.webhook.config != _|_ {
						{
							name: "config"
							configMap: name: #deployment_meta.name
						}
					},
					if #main_config.webhook.volumes != _|_ {
						for k, v in #main_config.webhook.volumes {v}
					},
				]
			}
		}
	}
}
