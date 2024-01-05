package templates

import (
	appsv1 "k8s.io/api/apps/v1"
	corev1 "k8s.io/api/core/v1"
	networkingv1 "k8s.io/api/networking/v1"
	timoniv1 "timoni.sh/core/v1alpha1"
)

// Config defines the schema and defaults for the Instance values.
#Config: {
	// Runtime version info
	moduleVersion!: string
	kubeVersion!:   string
	version!:       string

	// Metadata (common to all resources)
	metadata: timoniv1.#Metadata & {#Version: moduleVersion}
	metadata: labels: "\(timoniv1.#StdLabelPartOf)": "cert-manager"

	// Reference to one or more secrets to be used when pulling images
	// ref: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
	imagePullSecrets?: [...corev1.#LocalObjectReference]

	// Optional priority class to be used for the cert-manager pods
	priorityClassName?: string

	// Setup the Cluster RBAC roles and bindings
	rbac?: {
		// Aggregate ClusterRoles to Kubernetes default user-facing roles. Ref: https://kubernetes.io/docs/reference/access-authn-authz/rbac/#user-facing-roles
		aggregateClusterRoles: *true | bool
	}

	podSecurityAdmission: {
		mode:  "audit" | "warn" | *"enforce"
		level: "privileged" | "baseline" | *"restricted"
	}
	// Logging verbosity
	logLevel: *2 | int & >=0 & <=6

	leaderElection: {
		namespace:      *"kube-system" | string
		leaseDuration?: *"60s" | #Duration
		renewDeadline?: *"40s" | #Duration
		retryPeriod?:   *"15s" | #Duration
	}

	controller: #Controller

	webhook: #Webhook

	caInjector?: #CAInjector

	acmeSolver: {
		image!:          timoniv1.#Image
		imagePullPolicy: #ImagePullPolicy
	}

	// TODO: turn this into a Timoni Test
	// This startupapicheck is a Helm post-install hook that waits for the webhook
	// endpoints to become available.
	// The check is implemented using a Kubernetes Job- if you are injecting mesh
	// sidecar proxies into cert-manager pods, you probably want to ensure that they
	// are not injected into this Job's pod. Otherwise the installation may time out
	// due to the Job never being completed because the sidecar proxy does not exit.
	// See https://github.com/cert-manager/cert-manager/pull/4414 for context.
	startupAPICheck?: #StartupAPICheck
}

#Duration:        string & =~"^[+-]?((\\d+h)?(\\d+m)?(\\d+s)?(\\d+ms)?(\\d+(us|µs))?(\\d+ns)?)$"
#Percent:         string & =~"^(100|[1-9]?[0-9])%$"
#ImagePullPolicy: *corev1.#PullIfNotPresent | corev1.#enumPullPolicy

#Prometheus: {
	serviceMonitor?: {
		prometheusInstance: *"default" | string
		targetPort:         *"http-metrics" | int | string
		path:               *"/metrics" | string
		interval:           *"60s" | #Duration
		scrapeTimeout:      *"30s" | #Duration
		labels?:            timoniv1.#Labels
		annotations?:       timoniv1.#Annotations
		honorLabels:        *false | bool
		endpointAdditionalProperties: {[ string]: string}
	}
}

#Proxy: {
	httpProxy:  string
	httpsProxy: string
	noProxy:    string
}

#ServiceAccountData: {
	// Optional additional annotations to add to the controller's ServiceAccount
	annotations?: timoniv1.#Annotations
	// Optional additional labels to add to the webhook's ServiceAccount
	labels?: timoniv1.#Labels
	// Automount API credentials for a Service Account.
	automountServiceAccountToken: *true | bool
}

#SecurityContext: {
	runAsNonRoot: *true | bool
	seccompProfile: type: *"RuntimeDefault" | string
}

#ContainerSecurityContext: corev1.#SecurityContext & {
	allowPrivilegeEscalation: *false | bool
	readOnlyRootFilesystem:   *true | bool
	runAsNonRoot:             *true | bool
	capabilities:             corev1.#Capabilities & {
		drop: *["ALL"] | null | [...string]
	}
}

#PodDisruptionBudgetData: {
	minAvailable:   *1 | int | #Percent
	maxUnavailable: *1 | int | #Percent
}

#CommonData: {
	affinity?:                     corev1.#Affinity
	automountServiceAccountToken?: *true | bool
	containerSecurityContext:      #ContainerSecurityContext
	deploymentAnnotations?:        timoniv1.#Annotations
	deploymentLabels?:             timoniv1.#Labels
	enableServiceLinks:            *false | bool
	extraArgs?: [...string]
	extraEnvs?: [...corev1.#EnvVar]
	image!:               timoniv1.#Image
	imagePullPolicy:      #ImagePullPolicy
	livenessProbe?:       corev1.#Probe
	nodeSelector:         timoniv1.#Labels & {"kubernetes.io/os": "linux"}
	podAnnotations?:      timoniv1.#Annotations
	podDisruptionBudget?: #PodDisruptionBudgetData
	podLabels?:           timoniv1.#Labels
	proxy?:               #Proxy
	readinessProbe?:      corev1.#Probe
	replicas:             *1 | int32
	resources?:           timoniv1.#ResourceRequirements & {
		requests?: timoniv1.#ResourceRequirement & {
			cpu:    *"10m" | timoniv1.#CPUQuantity
			memory: *"32Mi" | timoniv1.#MemoryQuantity
		}
	}
	securityContext:     #SecurityContext
	serviceAccount?:     #ServiceAccountData
	serviceAnnotations?: timoniv1.#Annotations
	serviceLabels?:      timoniv1.#Labels
	serviceType:         *corev1.#ServiceTypeClusterIP | corev1.#enumServiceType
	strategy?:           appsv1.#DeploymentStrategy
	tolerations?: [ ...corev1.#Toleration]
	topologySpreadConstraints?: [...corev1.#TopologySpreadConstraint]
	volumeMounts?: [...corev1.#VolumeMount]
	volumes?: [...corev1.#Volume]
}

#Controller: {
	#CommonData
	clusterResourceNamespace?:      string
	dns01RecursiveNameservers?:     string
	dns01RecursiveNameserversOnly?: *false | bool
	enableCertificateOwnerRef?:     *false | bool
	featureGates?:                  string
	maxConcurrentChallenges:        *60 | int
	podDNSConfig?:                  corev1.#PodDNSConfig
	podDNSPolicy?:                  *"ClusterFirst" | "Default" | "ClusterFirstWithHostNet" | "None"
	prometheus?:                    #Prometheus

	// Used to configure options for the controller pod.
	// This allows setting options that'd usually be provided via flags.
	// An APIVersion and Kind must be specified in your values.yaml file.
	// Flags will override options that are set here.
	config?: {// TODO: Grab this from the Cert Manager repo instead of defining here
		apiVersion: *"controller.config.cert-manager.io/v1alpha1" | string
		kind:       *"ControllerConfiguration" | string
		logging: {
			verbosity: *2 | int & >=0 & <=6
			format:    *"text" | string
		}
		leaderElectionConfig: namespace: *"kube-system" | string
		kubernetesAPIQPS:          *9000 | int
		kubernetesAPIBurst:        *9000 | int
		numberOfConcurrentWorkers: *200 | int
		featureGates: {
			additionalCertificateOutputFormats:               *true | bool
			experimentalCertificateSigningRequestControllers: *true | bool
			experimentalGatewayAPISupport:                    *true | bool
			serverSideApply:                                  *true | bool
			literalCertificateSubject:                        *true | bool
			useCertificateRequestBasicConstraints:            *true | bool
		}
	}

	ingressShim?: {
		defaultIssuerName?:  string
		defaultIssuerKind?:  *"ClusterIssuer" | "Issuer"
		defaultIssuerGroup?: string
	}
}

#Webhook: {
	#CommonData
	featureGates?:                              string
	hostNetwork:                                *false | bool
	loadBalancerIP?:                            string
	mutatingWebhookConfigurationAnnotations?:   timoniv1.#Annotations
	networkPolicy?:                             networkingv1.#NetworkPolicySpec
	securePort:                                 *10250 | int
	timeoutSeconds:                             *10 | int
	validatingWebhookConfigurationAnnotations?: timoniv1.#Annotations
	livenessProbe: {}
	readinessProbe: {}
	args: [...string]

	// Used to configure options for the webhook pod.
	// This allows setting options that'd usually be provided via flags.
	// An APIVersion and Kind must be specified in your values.yaml file.
	// Flags will override options that are set here.
	config?: {
		apiVersion: *"webhook.config.cert-manager.io/v1alpha1" | string
		kind:       *"WebhookConfiguration" | string
		// The port that the webhook should listen on for requests.
		// In GKE private clusters, by default kubernetes apiservers are allowed to
		// talk to the cluster nodes only on 443 and 10250. so configuring
		// securePort: 10250, will work out of the box without needing to add firewall
		// rules or requiring NET_BIND_SERVICE capabilities to bind port numbers <1000.
		// This should be uncommented and set as a default by the chart once we graduate
		// the apiVersion of WebhookConfiguration past v1alpha1.
		securePort: *10250 | int
	}

	// Overrides the mutating webhook and validating webhook so they reach the webhook
	// service using the `url` field instead of a service.
	url: {
		host?: string
	}
}

#CAInjector: {
	#CommonData
	config?: {[string]: string}

	args: [...string]
}

#StartupAPICheck: {
	#CommonData
	backoffLimit:    *4 | int
	jobAnnotations?: timoniv1.#Annotations
	rbac: annotations?: timoniv1.#Annotations

	// Timeout for 'kubectl check api' command
	timeout: *"1m" | #Duration
}

// Instance takes the config values and outputs the Kubernetes objects.
#Instance: {
	config: #Config

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
		namespace:            #Namespace & {#config: config}
		controllerDeployment: #Deployment & {
			#config:     config
			#component:  "controller"
			#strategy:   #config.controller.strategy
			#prometheus: #config.controller.prometheus
		}
		webhookDeployment: #Deployment & {
			#config:    config
			#component: "webhook"
			#strategy:  #config.webhook.strategy
		}
		webhookMutatingWebhook:   #MutatingWebhook & {#config:   config}
		webhookValidatingWebhook: #ValidatingWebhook & {#config: config}
		webhookService:           #Service & {
			#config:    config
			#component: "webhook"
		}
	}

	if config.caInjector != _|_ {
		if config.caInjector.podDisruptionBudget != _|_ {
			objects: caInjectorPodDisruptionBudget: #PodDisruptionBudget & {
				#config:    config
				#component: "cainjector"
			}
		}

		if config.podSecurityPolicy != _|_ {
			objects: {
				caInjectorPSPClusterRole: #ClusterRole & {
					#config:    config
					#component: "cainjector"
				}
				caInjectorPSPClusterRoleBinding: #ClusterRoleBinding & {
					#config:    config
					#component: "cainjector"
				}
			}
		}

		if config.rbac != _|_ {
			objects: {
				caInjectorClusterRole: #ClusterRole & {
					#config:    config
					#component: "cainjector"
				}
				caInjectorClusterRoleBinding: #ClusterRoleBinding & {
					#config:    config
					#component: "cainjector"
				}
				caInjectorRole: #Role & {
					#config:    config
					#component: "cainjector"
				}
				caInjectorRoleBinding: #RoleBinding & {
					#config:    config
					#component: "cainjector"
				}
			}
		}

		if config.caInjector.serviceAccount != _|_ {
			objects: caInjectorServiceAccount: #ServiceAccount & {
				#config:    config
				#component: "cainjector"
			}
		}

		objects: caInjectorDeployment: #Deployment & {
			#config:    config
			#component: "cainjector"
			#strategy:  #config.caInjector.strategy
		}
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
			webhookNetworkPolicyIngress: #NetworkPolicyAllowIngress & {
				#config:    config
				#component: "webhook"
			}
		}
	}

	if config.controller.podDisruptionBudget != _|_ {
		objects: controllerPodDisruptionBudget: #PodDisruptionBudget & {
			#config:    config
			#component: "controller"
		}
	}

	if config.podSecurityPolicy != _|_ {
		objects: {
			controllerPSPClusterRole: #ClusterRole & {
				#config:    config
				#component: "controller"
			}
			controllerPSPClusterRoleBinding: #ClusterRoleBinding & {
				#config:    config
				#component: "controller"
			}

			webhookPSPClusterRole: #ClusterRole & {
				#config:    config
				#component: "webhook"
			}
			webhookPSPClusterRoleBinding: #ClusterRoleBinding & {
				#config:    config
				#component: "webhook"
			}
		}
	}

	if config.rbac != _|_ {
		objects: {
			controllerRole: #Role & {
				#config:    config
				#component: "controller"
			}
			controllerRoleBinding: #RoleBinding & {
				#config:    config
				#component: "controller"
			}

			clusterViewClusterRole: #ClusterRole & {
				#config:    config
				#component: "cluster-view"
			}
			viewClusterRole: #ClusterRole & {
				#config:    config
				#component: "view"
			}
			editClusterRole: #ClusterRole & {
				#config:    config
				#component: "edit"
			}

			controllerIssuersClusterRole: #ClusterRole & {
				#config:    config
				#component: "controller-issuers"
			}
			controllerClusterIssuersClusterRole: #ClusterRole & {
				#config:    config
				#component: "controller-cluster-issuer"
			}
			controllerCertificatesClusterRole: #ClusterRole & {
				#config:    config
				#component: "controller-certificates"
			}
			controllerOrdersClusterRole: #ClusterRole & {
				#config:    config
				#component: "controller-orders"
			}
			controllerChallengesClusterRole: #ClusterRole & {
				#config:    config
				#component: "controller-challenges"
			}
			controllerIngressShimClusterRole: #ClusterRole & {
				#config:    config
				#component: "controller-ingress-shim"
			}
			controllerApproveClusterRole: #ClusterRole & {
				#config:    config
				#component: "controller-approve"
			}
			controllerCertificateSigningRequestsClusterRole: #ClusterRole & {
				#config:    config
				#component: "controller-csr"
			}
			controllerIssuersClusterRoleBinding: #ClusterRoleBinding & {
				#config:    config
				#component: "controller-issuers"
			}
			controllerClusterIssuersClusterRoleBinding: #ClusterRoleBinding & {
				#config:    config
				#component: "controller-cluster-issuers"
			}
			controllerCertificatesClusterRoleBinding: #ClusterRoleBinding & {
				#config:    config
				#component: "controller-certificates"
			}
			controllerOrdersClusterRoleBinding: #ClusterRoleBinding & {
				#config:    config
				#component: "controller-orders"
			}
			controllerChallengesClusterRoleBinding: #ClusterRoleBinding & {
				#config:    config
				#component: "controller-challenges"
			}
			controllerIngressShimClusterRoleBinding: #ClusterRoleBinding & {
				#config:    config
				#component: "controller-ingress-shim"
			}
			controllerApproveClusterRoleBinding: #ClusterRoleBinding & {
				#config:    config
				#component: "controller-approve"
			}
			controllerCertificateSigningRequestsClusterRoleBinding: #ClusterRoleBinding & {
				#config:    config
				#component: "controller-csr"
			}

			webhookRole: #Role & {
				#config:    config
				#component: "webhook"
			}
			webhookRoleBinding: #RoleBinding & {
				#config:    config
				#component: "webhook"
			}
			webhookClusterRole: #ClusterRole & {
				#config:    config
				#component: "webhook"
			}
			webhookClusterRoleBinding: #ClusterRoleBinding & {
				#config:    config
				#component: "webhook"
			}
		}
	}

	if config.controller.prometheus != _|_ && config.controller.prometheus.serviceMonitor != _|_ {
		objects: {
			service: #Service & {
				#config:    config
				#component: "controller"
			}
			serviceMonitor: #ServiceMonitor & {
				#config:    config
				#component: "controller"
			}
		}
	}

	if config.controller.serviceAccount != _|_ {
		objects: controllerServiceAccount: #ServiceAccount & {
			#config:    config
			#component: "controller"
		}
	}

	if config.startupAPICheck != _|_ {
		objects: startupAPICheckJob: #StartupAPICheckJob & {#config: config}

		if config.podSecurityPolicy != _|_ {
			objects: {
				startupAPICheckPSPClusterRole: #ClusterRole & {
					#config:    config
					#component: "startup-api-check"
				}
				startupAPICheckPSPClusterRoleBinding: #ClusterRoleBinding & {
					#config:    config
					#component: "startup-api-check"
				}
			}
		}

		if config.rbac != _|_ {
			objects: {
				startupAPICheckRole: #Role & {
					#config:    config
					#component: "startupapicheck"
				}
				startupAPICheckRoleBinding: #RoleBinding & {
					#config:    config
					#component: "startupapicheck"
				}
			}
		}

		if config.startupAPICheck.serviceAccount != _|_ {
			objects: startupAPICheckServiceAccount: #ServiceAccount & {
				#config:    config
				#component: "startupapicheck"
			}
		}
	}

	if config.webhook.config != _|_ {
		objects: webhookConfigMap: #ConfigMap & {
			#config:    config
			#component: "webhook"
		}
	}

	if config.webhook.podDisruptionBudget != _|_ {
		objects: webhookPodDisruptionBudget: #PodDisruptionBudget & {
			#config:    config
			#component: "webhook"
		}
	}

	if config.webhook.serviceAccount != _|_ {
		objects: webhookServiceAccount: #ServiceAccount & {
			#config:    config
			#component: "webhook"
		}
	}
}
