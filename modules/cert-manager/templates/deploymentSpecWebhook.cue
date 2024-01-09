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

	replicas: #main_config.webhook.replicas
	selector: matchLabels: #deployment_meta.#LabelSelector

	if #deployment_strategy != _|_ {
		strategy: #deployment_strategy
	}
	template: corev1.#PodTemplateSpec & {
		metadata: labels: #deployment_meta.labels

		if #main_config.webhook.podLabels != _|_ {
			metadata: labels: #main_config.webhook.podLabels
		}

		if #main_config.webhook.podAnnotations != _|_ {
			metadata: annotations: #main_config.webhook.podAnnotations
		}

		spec: corev1.#PodSpec & {
			enableServiceLinks: #main_config.webhook.enableServiceLinks
			securityContext:    #main_config.webhook.securityContext
			serviceAccountName: #deployment_meta.name

			if #main_config.webhook.automountServiceAccountToken != _|_ {
				automountServiceAccountToken: #main_config.webhook.automountServiceAccountToken
			}

			if #main_config.priorityClass != _|_ {
				priorityClassName: #main_config.priorityClass
			}

			if #main_config.webhook.hostNetwork != false {
				hostNetwork: true
				dnsPolicy:   "ClusterFirstWithHostNet"
			}

			containers: [...corev1.#Container] & [
					{
					name: #deployment_meta.name

					image:           #main_config.webhook.image.reference
					imagePullPolicy: #main_config.webhook.image.pullPolicy

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
						readinessProbe: #main_config.webhook.livenessProbe & {
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

					if #main_config.webhook.containerSecurityContext != _|_ {
						securityContext: #main_config.webhook.containerSecurityContext
					}

					env: [
						{
							name: "POD_NAMESPACE"
							valueFrom: fieldRef: fieldPath: "metadata.namespace"
						},

						if #main_config.webhook.extraEnvs != _|_ {
							for e in #main_config.webhook.extraEnvs {e}
						},
					]

					if #main_config.webhook.resources != _|_ {
						resources: #main_config.webhook.resources
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

			if #main_config.webhook.nodeSelector != _|_ {
				nodeSelector: #main_config.webhook.nodeSelector
			}

			if #main_config.webhook.affinity != _|_ {
				affinity: #main_config.webhook.affinity
			}

			if #main_config.webhook.tolerations != _|_ {
				tolerations: #main_config.webhook.tolerations
			}

			if #main_config.webhook.topologySpreadConstraints != _|_ {
				topologySpreadConstraints: #main_config.webhook.topologySpreadConstraints
			}

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
