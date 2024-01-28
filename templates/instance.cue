package templates

import (
	cfg "timoni.sh/cert-manager/templates/config"
)

// Instance takes the config values and outputs the Kubernetes objects.
#Instance: {
	config: cfg.#Config

	objects: {
		for name, crd in customresourcedefinition {
			"\(name)": crd
			"\(name)": metadata: labels: config.metadata.labels
			if config.metadata.annotations != _|_ {
				"\(name)": metadata: annotations: config.metadata.annotations
			}
		}
	}

	objects: {
		namespace: #Namespace & {#config: config}
		controllerDeployment: #ControllerDeployment & {#config: config}
		webhookDeployment: #WebhookDeployment & {#config: config}
		webhookMutatingWebhook: #MutatingWebhook & {#config: config}
		webhookValidatingWebhook: #ValidatingWebhook & {#config: config}
		webhookService: #ServiceWebhook & {#config: config}
	}

	if config.caInjector != _|_ {
		if config.caInjector.podDisruptionBudget.enabled {
			objects: caInjectorPodDisruptionBudget: #PodDisruptionBudget & {
				#config:    config
				#component: "caInjector"
			}
		}

		if config.rbac.enabled {
			objects: {
				caInjectorClusterRole: #CaInjectorClusterRole & {
					#config:    config
					#component: "caInjector"
				}
				caInjectorClusterRoleBinding: #ClusterRoleBinding & {
					#config:    config
					#component: "caInjector"
				}
				caInjectorRole: #CaInjectorRole & {#config: config}
				caInjectorRoleBinding: #CaInjectorRoleBinding & {#config: config}
			}
		}

		objects: caInjectorServiceAccount: #ServiceAccount & {
			#config:    config
			#component: "caInjector"
		}

		objects: caInjectorDeployment: #CaInjectorrDeployment & {#config: config}
	}

	if config.controller.config != _|_ {
		objects: controllerConfigMap: #ConfigMap & {
			#config:    config
			#component: "controller"
		}
	}

	if config.webhook.networkPolicy != _|_ {
		objects: {
			webhookNetworkPolicyEgress: #NetworkPolicyAllowEgress & {
				#config:    config
				#component: "webhook"
			}
			webhookNetworkPolicyIngress:
				#NetworkPolicyAllowIngress & {
					#config:    config
					#component: "webhook"
				}
		}
	}

	if config.controller.podDisruptionBudget.enabled {
		objects: controllerPodDisruptionBudget: #PodDisruptionBudget & {
			#config:    config
			#component: "controller"
		}
	}

	if config.rbac.enabled {
		objects: {
			controllerRole: #ControllerRole & {#config: config}
			controllerRoleBinding: #ControllerRoleBinding & {#config: config}

			if config.rbac.aggregateClusterRoles {
				controllerClusterViewClusterRole: #ControllerClusterViewClusterRole & {
					#config: config
				}
			}
			controllerViewClusterRole: #ControllerViewClusterRole & {#config: config}
			controllerEditClusterRole: #ControllerEditClusterRole & {#config: config}
			controllerIssuersClusterRole: #ControllerIssuersClusterRole & {#config: config}
			controllerClusterIssuersClusterRole: #ControllerClusterIssuersClusterRole & {#config: config}
			controllerCertificatesClusterRole: #ControllerCertificatesClusterRole & {#config: config}
			controllerOrdersClusterRole: #ControllerOrdersClusterRole & {#config: config}
			controllerChallengesClusterRole: #ControllerChallengesClusterRole & {#config: config}
			controllerIngressShimClusterRole: #ControllerIngressShimClusterRole & {#config: config}
			controllerApproveClusterRole: #ControllerApproveClusterRole & {#config: config}
			controllerCertificateSigningRequestsClusterRole: #ControllerCertificateSigningRequestsClusterRole & {#config: config}

			controllerIssuersClusterRoleBinding: #ClusterRoleBinding & {
				#config:    config
				#component: "controller"
				#role:      "issuers"
			}
			controllerClusterIssuersClusterRoleBinding: #ClusterRoleBinding & {
				#config:    config
				#component: "controller"
				#role:      "clusterissuers"
			}
			controllerCertificatesClusterRoleBinding: #ClusterRoleBinding & {
				#config:    config
				#component: "controller"
				#role:      "certificates"
			}
			controllerOrdersClusterRoleBinding: #ClusterRoleBinding & {
				#config:    config
				#component: "controller"
				#role:      "orders"
			}
			controllerChallengesClusterRoleBinding: #ClusterRoleBinding & {
				#config:    config
				#component: "controller"
				#role:      "challenges"
			}
			controllerIngressShimClusterRoleBinding: #ClusterRoleBinding & {
				#config:    config
				#component: "controller"
				#role:      "ingress-shim"
			}
			controllerApproveClusterRoleBinding: #ClusterRoleBinding & {
				#config:    config
				#component: "controller"
				#role:      "approve:cert-manager-io"
			}
			controllerCertificateSigningRequestsClusterRoleBinding: #ClusterRoleBinding & {
				#config:    config
				#component: "controller"
				#role:      "certificatesigningrequests"
			}

			webhookRole: #WebhookRole & {#config: config}
			webhookRoleBinding: #WebhookRoleBinding & {#config: config}
			webhookClusterRole: #ClusterWebhookClusterRole & {#config: config}
			webhookClusterRoleBinding: #ClusterRoleBinding & {
				#config:    config
				#component: "webhook"
				#role:      "subjectaccessreviews"
			}
		}
	}

	if config.controller.monitoring.enabled && config.controller.monitoring.serviceMonitor.enabled {
		objects: {
			service: #ServiceController & {#config: config}
			serviceMonitor: #ServiceMonitor & {
				#config:    config
				#component: "controller"
			}
		}
	}

	objects: controllerServiceAccount: #ServiceAccount & {
		#config:    config
		#component: "controller"
	}

	if config.webhook.config != _|_ {
		objects: webhookConfigMap: #ConfigMap & {
			#config:    config
			#component: "webhook"
		}
	}

	if config.webhook.podDisruptionBudget.enabled {
		objects: webhookPodDisruptionBudget: #PodDisruptionBudget & {
			#config:    config
			#component: "webhook"
		}
	}

	objects: webhookServiceAccount: #ServiceAccount & {
		#config:    config
		#component: "webhook"
	}

	if config.test != _|_ {
		tests: startupAPICheckJob: #StartupAPICheckJob & {#config: config}

		if config.rbac.enabled {
			tests: {
				startupAPICheckRole: #StartupApiCheckRole & {#config: config}
				startupAPICheckRoleBinding: #StartupApiCheckRoleBinding & {#config: config}
			}
		}

		tests: startupAPICheckServiceAccount: #ServiceAccount & {
			#config:    config
			#component: "startupAPICheck"
		}
	}
}
