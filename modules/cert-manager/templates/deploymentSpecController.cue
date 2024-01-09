package templates

import (
	appsv1 "k8s.io/api/apps/v1"
	corev1 "k8s.io/api/core/v1"
	timoniv1 "timoni.sh/core/v1alpha1"

	cfg "timoni.sh/cert-manager/templates/config"
)

#ControllerDeploymentSpec: appsv1.#DeploymentSpec & {
	#main_config:            cfg.#Config
	#deployment_meta:        timoniv1.#MetaComponent
	#deployment_strategy?:   appsv1.#DeploymentStrategy
	#deployment_monitoring?: cfg.#Monitoring

	replicas: #main_config.controller.replicas
	selector: matchLabels: #deployment_meta.#LabelSelector

	if #deployment_strategy != _|_ {
		strategy: #deployment_strategy
	}

	template: corev1.#PodTemplateSpec & {
		metadata: labels: #deployment_meta.labels

		if #main_config.controller.podLabels != _|_ {
			metadata: labels: #main_config.controller.podLabels
		}

		if #main_config.controller.podAnnotations != _|_ {
			metadata: annotations: #main_config.controller.podAnnotations
		}

		if #deployment_monitoring != _|_ && #deployment_monitoring.serviceMonitor == _|_ {
			metadata: annotations: "prometheus.io/path":   "/metrics"
			metadata: annotations: "prometheus.io/scrape": "true"
			metadata: annotations: "prometheus.io/port":   "9402"
		}

		spec: corev1.#PodSpec & {
			serviceAccountName: #deployment_meta.name

			if #main_config.controller.automountServiceAccountToken != _|_ {
				automountServiceAccountToken: #main_config.controller.automountServiceAccountToken
			}

			if #main_config.controller.enableServiceLinks != _|_ {
				enableServiceLinks: #main_config.controller.enableServiceLinks
			}

			if #main_config.priorityClass != _|_ {
				priorityClassName: #main_config.priorityClass
			}

			securityContext: #main_config.controller.securityContext

			if #main_config.controller.volumes != _|_ || #main_config.controller.config != _|_ {
				volumes: [
					if #main_config.controller.config != _|_ {
						{
							name: "config"
							configMap: name: #deployment_meta.name
						}
					},
					if #main_config.controller.volumes != _|_ {
						for k, v in #main_config.controller.volumes {
							v
						}
					},
				]
			}

			containers: [...corev1.#Container] & [
					{
					name: #deployment_meta.name

					image:           #main_config.controller.image.reference
					imagePullPolicy: #main_config.controller.image.pullPolicy

					if #main_config.controller.containerSecurityContext != _|_ {
						securityContext: #main_config.controller.containerSecurityContext
					}

					if #main_config.controller.volumeMounts != _|_ || #main_config.controller.config != _|_ {
						volumeMounts: [
							if #main_config.controller.config != _|_ {
								name:      "config"
								mountPath: "/var/cert-manager/config"
							},
							if #main_config.controller.volumeMounts != _|_ {
								for k, v in #main_config.controller.volumeMounts {v}
							},
						]
					}

					ports: [{
						containerPort: 9402
						name:          "http-metrics"
						protocol:      "TCP"
					}, {
						containerPort: 9403
						name:          "http-healthz"
						protocol:      "TCP"
					}]

					args: [
						"--v=\(#main_config.logLevel)",
						"--leader-election-namespace=\(#main_config.leaderElection.namespace)",
						"--acme-http01-solver-image=\(#main_config.acmeSolver.image.reference)",

						if #main_config.controller.config != _|_ {
							"--config=/var/cert-manager/config/config.yaml"
						},

						if #main_config.controller.clusterResourceNamespace != _|_ {
							"--cluster-resource-namespace=\(#main_config.controller.clusterResourceNamespace)"
						},

						if #main_config.controller.clusterResourceNamespace == _|_ {
							"--cluster-resource-namespace=$(POD_NAMESPACE)"
						},

						if #main_config.leaderElection.leaseDuration != _|_ {
							"--leader-election-lease-duration=\(#main_config.leaderElection.leaseDuration)"
						},

						if #main_config.leaderElection.renewDeadline != _|_ {
							"--leader-election-renew-deadline=\(#main_config.leaderElection.renewDeadline)"
						},

						if #main_config.leaderElection.retryPeriod != _|_ {
							"--leader-election-retry-period=\(#main_config.leaderElection.retryPeriod)"
						},

						if #main_config.controller.ingressShim != _|_ && #main_config.controller.ingressShim.defaultIssuerName != _|_ {
							"--default-issuer-name=\(#main_config.controller.ingressShim.defaultIssuerName)"
						},

						if #main_config.controller.ingressShim != _|_ && #main_config.controller.ingressShim.defaultIssuerKind != _|_ {
							"--default-issuer-kind=\(#main_config.controller.ingressShim.defaultIssuerKind)"
						},

						if #main_config.controller.ingressShim != _|_ && #main_config.controller.ingressShim.defaultIssuerGroup != _|_ {
							"--default-issuer-group=\(#main_config.controller.ingressShim.defaultIssuerGroup)"
						},

						if #main_config.controller.featureGates != _|_ {
							"--feature-gates=\(#main_config.controller.featureGates)"
						},

						if #main_config.controller.maxConcurrentChallenges != _|_ {
							"--max-concurrent-challenges=\(#main_config.controller.maxConcurrentChallenges)"
						},

						if #main_config.controller.enableCertificateOwnerRef != _|_ {
							"--enable-certificate-owner-ref=true"
						},

						if #main_config.controller.dns01RecursiveNameserversOnly != _|_ {
							"--dns01-recursive-nameservers-only=true"
						},

						if #main_config.controller.dns01RecursiveNameservers != _|_ {
							"--dns01-recursive-nameservers=\(#main_config.controller.dns01RecursiveNameservers)"
						},

						if #main_config.controller.extraArgs != _|_ {
							for a in #main_config.controller.extraArgs {a}
						},
					]

					env: [
						{
							name: "POD_NAMESPACE"
							valueFrom: fieldRef: fieldPath: "metadata.namespace"
						},

						if #main_config.controller.extraEnvs != _|_ {
							for e in #main_config.controller.extraEnvs {e}
						},
					]

					if #main_config.controller.proxy != _|_ {
						env: [
							if #main_config.controller.proxy.httpProxy != _|_ {
								{
									name:  "HTTP_PROXY"
									value: #main_config.controller.proxy.httpProxy
								}
							},
							if #main_config.controller.proxy.httpsProxy != _|_ {
								{
									name:  "HTTP_PROXY"
									value: #main_config.controller.proxy.httpsProxy
								}
							},
							if #main_config.controller.proxy.noProxy != _|_ {
								{
									name:  "HTTP_PROXY"
									value: #main_config.controller.proxy.noProxy
								}
							},
						]
					}

					if #main_config.controller.resources != _|_ {
						resources: #main_config.controller.resources
					}

					if #main_config.controller.livenessProbe != _|_ {
						livenessProbe: #main_config.controller.livenessProbe & {
							httpGet: {
								port:   "http-healthz"
								path:   "/livez"
								scheme: "HTTP"
							}
							initialDelaySeconds: *10 | int
							periodSeconds:       *10 | int
							timeoutSeconds:      *15 | int
							successThreshold:    *1 | int
							failureThreshold:    *8 | int
						}
					}
				},
			]

			if #main_config.controller.nodeSelector != _|_ {
				nodeSelector: #main_config.controller.nodeSelector
			}

			if #main_config.controller.affinity != _|_ {
				affinity: #main_config.controller.affinity
			}

			if #main_config.controller.tolerations != _|_ {
				tolerations: #main_config.controller.tolerations
			}

			if #main_config.controller.topologySpreadConstraints != _|_ {
				topologySpreadConstraints: #main_config.controller.topologySpreadConstraints
			}

			if #main_config.controller.podDNSPolicy != _|_ {
				dnsPolicy: #main_config.controller.podDNSPolicy
			}

			if #main_config.controller.podDNSConfig != _|_ {
				dnsConfig: #main_config.controller.podDNSConfig
			}
		}
	}
}
