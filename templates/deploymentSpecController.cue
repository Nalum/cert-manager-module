package templates

import (
	appsv1 "k8s.io/api/apps/v1"
	corev1 "k8s.io/api/core/v1"
	timoniv1 "timoni.sh/core/v1alpha1"

	cfg "timoni.sh/cert-manager/templates/config"
)

#ControllerDeploymentSpec: appsv1.#DeploymentSpec & {
	#main_config:           cfg.#Config
	#deployment_meta:       timoniv1.#MetaComponent
	#deployment_monitoring: cfg.#Monitoring

	selector: matchLabels: #deployment_meta.#LabelSelector

	template: corev1.#PodTemplateSpec & {
		if #deployment_monitoring.enabled && !#deployment_monitoring.serviceMonitor.enabled {
			metadata: annotations: "prometheus.io/path":   "/metrics"
			metadata: annotations: "prometheus.io/scrape": "true"
			metadata: annotations: "prometheus.io/port":   "9402"
		}

		spec: corev1.#PodSpec & {
			volumes: [
				for k, v in #main_config.controller.volumes {v},

				if #main_config.controller.config != _|_ {
					{
						name: "config"
						configMap: name: #deployment_meta.name
					}
				},
			]

			dnsPolicy: #main_config.controller.podDNSPolicy

			if #main_config.controller.podDNSConfig != _|_ {
				dnsConfig: #main_config.controller.podDNSConfig
			}

			containers: [...corev1.#Container] & [
				{
					volumeMounts: [
						for k, v in #main_config.controller.volumeMounts {v},

						if #main_config.controller.config != _|_ {
							name:      "config"
							mountPath: "/var/cert-manager/config"
						},
					]

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
						"--max-concurrent-challenges=\(#main_config.controller.maxConcurrentChallenges)",

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

						if #main_config.controller.enableCertificateOwnerRef {
							"--enable-certificate-owner-ref=true"
						},

						if #main_config.controller.dns01RecursiveNameserversOnly {
							"--dns01-recursive-nameservers-only=true"
						},

						if #main_config.controller.dns01RecursiveNameservers != _|_ {
							"--dns01-recursive-nameservers=\(#main_config.controller.dns01RecursiveNameservers)"
						},

						if #main_config.controller.extraArgs != _|_ {
							for a in #main_config.controller.extraArgs {a}
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
									name:  "HTTPS_PROXY"
									value: #main_config.controller.proxy.httpsProxy
								}
							},
							if #main_config.controller.proxy.noProxy != _|_ {
								{
									name:  "NO_PROXY"
									value: #main_config.controller.proxy.noProxy
								}
							},
						]
					}

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
				},
			]
		}
	}
}
