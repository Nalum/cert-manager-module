package templates

import (
	appsv1 "k8s.io/api/apps/v1"
	corev1 "k8s.io/api/core/v1"
	timoniv1 "timoni.sh/core/v1alpha1"
)

#WebhookDeploymentSpec: appsv1.#DeploymentSpec & {
	_main_config:          #Config
	_deployment_meta:      timoniv1.#MetaComponent
	_deployment_strategy?: appsv1.#DeploymentStrategy

	replicas: _main_config.webhook.replicas
	selector: matchLabels: _deployment_meta.#LabelSelector

	if _deployment_strategy != _|_ {
		strategy: _deployment_strategy
	}
	template: corev1.#PodTemplateSpec & {
		metadata: labels: _deployment_meta.labels

		if _main_config.webhook.podLabels != _|_ {
			metadata: labels: _main_config.webhook.podLabels
		}

		if _main_config.webhook.podAnnotations != _|_ {
			metadata: annotations: _main_config.webhook.podAnnotations
		}

		spec: corev1.#PodSpec & {
			enableServiceLinks: _main_config.webhook.enableServiceLinks
			securityContext:    _main_config.webhook.securityContext
			serviceAccountName: _deployment_meta.name

			if _main_config.webhook.automountServiceAccountToken != _|_ {
				automountServiceAccountToken: _main_config.webhook.automountServiceAccountToken
			}

			if _main_config.priorityClass != _|_ {
				priorityClassName: _main_config.priorityClass
			}

			if _main_config.webhook.hostNetwork != false {
				hostNetwork: true
				dnsPolicy:   "ClusterFirstWithHostNet"
			}

			containers: [...corev1.#Container] & [
					{
					name: _deployment_meta.name

					image:           _main_config.webhook.image.reference
					imagePullPolicy: _main_config.webhook.imagePullPolicy

					args: [
						"--v=\(_main_config.logLevel)",

						if _main_config.webhook.config != _|_ {
							"--secure-port=\(_main_config.webhook.config.securePort)"
						},

						if _main_config.webhook.config == _|_ {
							"--secure-port=\(_main_config.webhook.securePort)"
						},

						if _main_config.webhook.config != _|_ {
							"--config=/var/cert-manager/config/config.yaml"
						},

						if _main_config.webhook.featureGates != _|_ {
							"--feature-gates=\(_deployment_meta.webhook.featureGates)"
						},

						if _main_config.webhook.config.tlsConfig == _|_ || (_main_config.webhook.config.tlsConfig.dynamic == _|_ && _main_config.webhook.config.tlsConfig.filesystem == _|_) {
							"--dynamic-serving-ca-secret-namespace=$(POD_NAMESPACE)"
						},

						if _main_config.webhook.config.tlsConfig == _|_ || (_main_config.webhook.config.tlsConfig.dynamic == _|_ && _main_config.webhook.config.tlsConfig.filesystem == _|_) {
							"--dynamic-serving-ca-secret-name=\(_deployment_meta.name)-ca"
						},

						if _main_config.webhook.config.tlsConfig == _|_ || (_main_config.webhook.config.tlsConfig.dynamic == _|_ && _main_config.webhook.config.tlsConfig.filesystem == _|_) {
							"--dynamic-serving-dns-names=\(_deployment_meta.name)"
						},

						if _main_config.webhook.config.tlsConfig == _|_ || (_main_config.webhook.config.tlsConfig.dynamic == _|_ && _main_config.webhook.config.tlsConfig.filesystem == _|_) {
							"--dynamic-serving-dns-names=\(_deployment_meta.name).$(POD_NAMESPACE)"
						},

						if _main_config.webhook.config.tlsConfig == _|_ || (_main_config.webhook.config.tlsConfig.dynamic == _|_ && _main_config.webhook.config.tlsConfig.filesystem == _|_) {
							"--dynamic-serving-dns-names=\(_deployment_meta.name).$(POD_NAMESPACE).svc"
						},

						if (_main_config.webhook.config.tlsConfig == _|_ || (_main_config.webhook.config.tlsConfig.dynamic == _|_ && _main_config.webhook.config.tlsConfig.filesystem == _|_)) && _main_config.webhook.url.host != _|_ {
							"--dynamic-serving-dns-names=\(_main_config.webhook.url.host)"
						},

						if _main_config.webhook.extraArgs != _|_ {
							for a in _main_config.webhook.extraArgs {a}
						},
					]

					ports: [
						{
							name:     "https"
							protocol: "TCP"
							if _main_config.webhook.config != _|_ {
								containerPort: _main_config.webhook.config.securePort
							}
							if _main_config.webhook.config == _|_ {
								containerPort: _main_config.webhook.securePort
							}
						},
						{
							name:          "healthcheck"
							protocol:      "TCP"
							containerPort: *6080 | _main_config.webhook.config.healthzPort
						},
					]

					if _main_config.webhook.livenessProbe != _|_ {
						livenessProbe: _main_config.webhook.livenessProbe & {
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

					if _main_config.webhook.readinessProbe != _|_ {
						readinessProbe: _main_config.webhook.livenessProbe & {
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

					if _main_config.webhook.containerSecurityContext != _|_ {
						securityContext: _main_config.webhook.containerSecurityContext
					}

					env: [
						{
							name: "POD_NAMESPACE"
							valueFrom: fieldRef: fieldPath: "metadata.namespace"
						},

						if _main_config.webhook.extraEnvs != _|_ {
							for e in _main_config.webhook.extraEnvs {e}
						},
					]

					if _main_config.webhook.resources != _|_ {
						resources: _main_config.webhook.resources
					}

					if _main_config.webhook.volumeMounts != _|_ || _main_config.webhook.config != _|_ {
						volumeMounts: [
							if _main_config.webhook.config != _|_ {
								{
									name:      "config"
									mountPath: "/var/cert-manager/config"
								}
							},
							if _main_config.webhook.volumeMounts != _|_ {
								_main_config.webhook.volumeMounts
							},
						]
					}
				},
			]

			if _main_config.webhook.nodeSelector != _|_ {
				nodeSelector: _main_config.webhook.nodeSelector
			}

			if _main_config.webhook.affinity != _|_ {
				affinity: _main_config.webhook.affinity
			}

			if _main_config.webhook.tolerations != _|_ {
				tolerations: _main_config.webhook.tolerations
			}

			if _main_config.webhook.topologySpreadConstraints != _|_ {
				topologySpreadConstraints: _main_config.webhook.topologySpreadConstraints
			}

			if _main_config.webhook.volumes != _|_ || _main_config.webhook.config != _|_ {
				volumes: [
					if _main_config.webhook.config != _|_ {
						{
							name: "config"
							configMap: name: _deployment_meta.name
						}
					},
					if _main_config.webhook.volumes != _|_ {
						_main_config.webhook.volumes
					},
				]
			}
		}
	}
}
