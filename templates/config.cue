package templates

import (
	corev1 "k8s.io/api/core/v1"
	timoniv1 "timoni.sh/core/v1alpha1"
)

// Config defines the schema and defaults for the Instance values.
#Config: {
	// Runtime version info
	moduleVersion!: string
	kubeVersion!:   string

	// Metadata (common to all resources)
	metadata: timoniv1.#Metadata & {#Version: moduleVersion}

	// Label selector (common to all resources)
	selector: timoniv1.#Selector & {#Name: metadata.name}

	// Pod Security Policy
	podSecurityPolicy: {
		enabled: *false | bool
		useAppArmor: *true | bool
	}

	// Logging verbosity
	logLevel: *2 | int & >=0 & <=6

	// Reference to one or more secrets to be used when pulling images
	// ref: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
	imagePullSecrets?: [...corev1.LocalObjectReference]

	// Labels to apply to all resources
	// Please note that this does not add labels to the resources created dynamically by the controllers.
	// For these resources, you have to add the labels in the template in the cert-manager custom resource:
	// eg. podTemplate/ ingressTemplate in ACMEChallengeSolverHTTP01Ingress
	//    ref: https://cert-manager.io/docs/reference/api-docs/#acme.cert-manager.io/v1.ACMEChallengeSolverHTTP01Ingress
	// eg. secretTemplate in CertificateSpec
	//    ref: https://cert-manager.io/docs/reference/api-docs/#cert-manager.io/v1.CertificateSpec
	commonLabels?: {[string & =~"^(([A-Za-z0-9][-A-Za-z0-9_./]*)?[A-Za-z0-9])?$" & strings.MaxRunes(63)]: string & =~"^(([A-Za-z0-9][-A-Za-z0-9_.]*)?[A-Za-z0-9])?$" & strings.MaxRunes(63)}

	// Optional priority class to be used for the cert-manager pods
	priorityClassName: string

	// Setup the Cluster RBAC roles and bindings
	rbac: {
		create: *true | bool
		// Aggregate ClusterRoles to Kubernetes default user-facing roles. Ref: https://kubernetes.io/docs/reference/access-authn-authz/rbac/#user-facing-roles
		aggregateClusterRoles: *true | bool
	}

	leaderElection: {
		namespace: *"kube-system" | string
		leaseDuration: *"60s" | #Duration
		renewDeadline: *"40s" | #Duration
		retryPeriod: *"15s" | #Duration
	}

	installCRDs: *false | bool

	replicaCount: *1 | int

	strategy?: corev1.#DeploymentStrategy

	podDisruptionBudget: {
		enabled: *false | bool
		minAvailable: *1 | int | #Percent
		maxUnavailable: *1 | int | #Percent
	}

	// Pod
	podAnnotations?: {[ string]: string}
	podSecurityContext?: corev1.#PodSecurityContext
	tolerations?: [ ...corev1.#Toleration]
	affinity?: corev1.#Affinity
	topologySpreadConstraints?: [...corev1.#TopologySpreadConstraint]

	// Container
	image!:           timoniv1.#Image
	imagePullPolicy:  *"IfNotPresent" | string
	resources?:       corev1.#ResourceRequirements
	securityContext?: corev1.#SecurityContext

	// Service
	service: port: *80 | int & >0 & <=65535

	// Test Job
	test: {
		enabled: *false | bool
		image!:  timoniv1.#Image
	}
}

#Duration: string & =~"^[0-9]+(ns|us|µs|ms|s|m|h)$"
#Percent: string & =~"^(1)?([1-9])?([0-9])%$"

// Instance takes the config values and outputs the Kubernetes objects.
#Instance: {
	config: #Config

	objects: {
		deployment: #Deployment & {_config: config}
		webhookDeployment: #Deployment & {_config: config}
		webhookMutatingWebhook: #MutatingWebhook & {_config: config}
		webhookValidatingWebhook: #ValidatingWebhook & {_config: config}
		webhookService: #Service & {_config: config}
	}

	if config.caInjector.enabled {
		if config.caInjector.config {
			objects: caInjectorConfigMap: #ConfigMap & {_config: config}
		}

		if config.caInjector.podDisruptionBudget.enabled {
			objects: caInjectorPodDisruptionBudget: #PodDisruptionBudget & {_config: config}
		}

		if config.podSecurityPolicy.enbaled {
			objects: {
				caInjectorPSPClusterRole: #ClusterRole & {_config: config}
				caInjectorPSPClusterRoleBinding: #ClusterRoleBinding & {_config: config}
				caInjectorPSP: #PodSecurityPolicy & {_config: config}
			}
		}

		if config.rbac.create {
			objects: {
				caInjectorClusterRole: #ClusterRole & {_config: config}
				caInjectorClusterRoleBinding: #ClusterRoleBinding & {_config: config}
				caInjectorRole: #Role & {_config: config}
				caInjectorRoleBinding: #RoleBinding & {_config: config}
			}
		}

		if config.caInjector.serviceAccount.enabled {
			objects: caInjectorServiceAccount: #ServiceAccount & {_config: config}
		}

		objects: caInjectorDeployment: #Deployment & {_config: config}
	}

	if config.config.enabled {
		objects: controllerConfigMap: #ConfigMap & {_config: config}
	}

	if config.webhook.networkPolicy.enabled {
		objects: {
			networkPolicyEgress: #NetworkPolicy & {_config: config}
			networkPolicyWebhooks: #NetworkPolicy & {_config: config}
		}
	}

	if config.podDisruptionBudget.enabled {
		objects: podDisruptionBudget: #PodDisruptionBudget & {_config: config}
	}

	if config.prometheus.enabled && config.prometheus.podMonitor.enabled {
		objects: podMonitor: #PodMonitor & {_config: config}
	}

	if config.podSecurityPolicy.enbaled {
		objects: {
			pspClusterRole: #ClusterRole & {_config: config}
			pspClusterRoleBinding: #ClusterRoleBinding & {_config: config}
			podSecurityPolicy: #PodSecurityPolicy & {_config: config}

			webhookPSPClusterRole: #ClusterRole & {_config: config}
			webhookPSPClusterRoleBinding: #ClusterRoleBinding & {_config: config}
			webhookPSP: #PodSecurityPolicy & {_config: config}
		}
	}

	if config.rbac.create {
		objects: {
			leaderElectionRole: #Role & {_config: config}
			leaderElectionRoleBinding: #RoleBinding & {_config: config}

			clusterViewClusterRole: #ClusterRole & {_config: config}
			viewClusterRole: #ClusterRole & {_config: config}
			editClusterRole: #ClusterRole & {_config: config}

			controllerIssuersClusterRole: #ClusterRole & {_config: config}
			controllerClusterIssuersClusterRole: #ClusterRole & {_config: config}
			controllerCertificatesClusterRole: #ClusterRole & {_config: config}
			controllerOrdersClusterRole: #ClusterRole & {_config: config}
			controllerChallengesClusterRole: #ClusterRole & {_config: config}
			controllerIngressShimClusterRole: #ClusterRole & {_config: config}
			controllerApproveClusterRole: #ClusterRole & {_config: config}
			controllerCertificateSigningRequestsClusterRole: #ClusterRole & {_config: config}
			controllerIssuersClusterRoleBinding: #ClusterRoleBinding & {_config: config}
			controllerClusterIssuersClusterRoleBinding: #ClusterRoleBinding & {_config: config}
			controllerCertificatesClusterRoleBinding: #ClusterRoleBinding & {_config: config}
			controllerOrdersClusterRoleBinding: #ClusterRoleBinding & {_config: config}
			controllerChallengesClusterRoleBinding: #ClusterRoleBinding & {_config: config}
			controllerIngressShimClusterRoleBinding: #ClusterRoleBinding & {_config: config}
			controllerApproveClusterRoleBinding: #ClusterRoleBinding & {_config: config}
			controllerCertificateSigningRequestsClusterRoleBinding: #ClusterRoleBinding & {_config: config}

			webhookRole: #Role & {_config: config}
			webhookRoleBinding: #RoleBinding & {_config: config}
			webhookClusterRole: #ClusterRole & {_config: config}
			webhookClusterRoleBinding: #ClusterRoleBinding & {_config: config}
		}
	}

	if config.prometheus.enabled && config.prometheus.serviceMonitor.enabled {
		objects: {
			service: #Service & {_config: config}
			serviceMonitor: #ServiceMonitor & {_config: config}
		}
	}

	if config.serviceAccount.create {
		objects: serviceAccount: #ServiceAccount & {_config: config}
	}

	if config.startupAPICheck.enabled {
		objects: startupAPICheckJob: #Job & {_config: config}

		if config.podSecurityPolicy.enbaled {
			objects: {
				startupAPICheckPSPClusterRole: #ClusterRole & {_config: config}
				startupAPICheckPSPClusterRoleBinding: #ClusterRoleBinding & {_config: config}
				startupAPICheckPSP: #PodSecurityPolicy & {_config: config}
			}
		}

		if config.rbac.create {
			objects: {
				startupAPICheckRole: #Role & {_config: config}
				startupAPICheckRoleBinding: #RoleBinding & {_config: config}
			}
		}

		if config.startupAPICheck.serviceAccount.create {
			objects: startupAPICheckServiceAccount: #ServiceAccount & {_config: config}
		}
	}

	if config.webhook.config {
		objects: webhookConfigMap: #ConfigMap & {_config: config}
	}

	if config.webhook.podDisruptionBudget.enabled {
		objects: webhookPodDisruptionBudget: #PodDisruptionBudget & {_config: config}
	}

	if config.webhook.serviceAccount.create {
		objects: webhookServiceAccount: #ServiceAccount & {_config: config}
	}

	tests: {
		"test-svc": #TestJob & {_config: config}
	}
}
