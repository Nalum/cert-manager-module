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
	commonLabels?: #Labels

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

	// Comma separated list of feature gates that should be enabled on the controller pod.
	featureGates?: string

	// The maximum number of challenges that can be scheduled as 'processing' at once
	maxConcurrentChallenges: *60 | int

	image!:           timoniv1.#Image & {repository: "quay.io/jetstack/cert-manager-controller", tag: "v1.13.2"}
	imagePullPolicy:  *"IfNotPresent" | string

	// Override the namespace used to store DNS provider credentials etc. for ClusterIssuer
	// resources. By default, the same namespace as cert-manager is deployed within is
	// used. This namespace will not be automatically created.
	clusterResourceNamespace?: string

	// This namespace allows you to define where the services will be installed into
	// if not set then they will use the namespace of the release
	// This is helpful when installing cert manager as a chart dependency (sub chart)
	namespace?: string

	serviceAccount: {
		// Specifies whether a service account should be created
		create: *true | bool
		// The name of the service account to use.
		// If not set and create is true, a name is generated using the fullname template
		name: *"" | string
		// Optional additional annotations to add to the controller's ServiceAccount
		annotations: #Annotations
		// Automount API credentials for a Service Account.
		automountServiceAccountToken: *true | bool
		// Optional additional labels to add to the controller's ServiceAccount
		labels: #Labels
	}

	// Automounting API credentials for a particular pod
	automountServiceAccountToken: *true | bool

	// When this flag is enabled, secrets will be automatically removed when the certificate resource is deleted
	enableCertificateOwnerRef: *false | bool

	// Used to configure options for the controller pod.
	// This allows setting options that'd usually be provided via flags.
	// An APIVersion and Kind must be specified in your values.yaml file.
	// Flags will override options that are set here.
	config: { // TODO: Grab this from the Cert Manager repo instead of defining here
		apiVersion: *"controller.config.cert-manager.io/v1alpha1" | string
		kind: *"ControllerConfiguration" | string
		logging: {
			verbosity: *2 | int & >=0 & <=6
			format: *"text" | string
		}
		leaderElectionConfig: namespace: *"kube-system" | string
		kubernetesAPIQPS: *9000 | int & >0 & <=65535
		kubernetesAPIBurst: *9000 | int & >0 & <=65535
		numberOfConcurrentWorkers: *200 | int
		featureGates: {
			additionalCertificateOutputFormats: *true | bool
			experimentalCertificateSigningRequestControllers: *true | bool
			experimentalGatewayAPISupport: *true | bool
			serverSideApply: *true | bool
			literalCertificateSubject: *true | bool
			useCertificateRequestBasicConstraints: *true | bool
		}
	}

	// Setting Nameservers for DNS01 Self Check
	// See: https://cert-manager.io/docs/configuration/acme/dns01/#setting-nameservers-for-dns01-self-check
	// Comma separated string with host and port of the recursive nameservers cert-manager should query
	dns01RecursiveNameservers?: string

	// Forces cert-manager to only use the recursive nameservers for verification.
	// Enabling this option could cause the DNS01 self check to take longer due to caching performed by the recursive nameservers
	dns01RecursiveNameserversOnly: *false | bool

	// Additional command line flags to pass to cert-manager controller binary.
	// To see all available flags run docker run quay.io/jetstack/cert-manager-controller:<version> --help
	extraArgs: [...string]
	//# Use this flag to enable or disable arbitrary controllers, for example, disable the CertificiateRequests approver
	//# --controllers=*,-certificaterequests-approver

	extraEnv: [...corev1.EnvVar]

	resources?: corev1.#ResourceRequirements & {requests: {cpu: "10m", memory: "32Mi"}}
	securityContext?: corev1.#SecurityContext & {runAsNonRoot: true, seccompProfile: type: "RuntimeDefault"}

	// Container Security Context to be set on the controller component container
	// ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
	containerSecurityContext?: corev1.#ContainerSecurityContext & {allowPrivilegeEscalation: false, capabilities: {drop: ["ALL"], readOnlyRootFilesystem: true, runAsNonRoot: true}}

	volumes?: [...corev1.#Volume]
	volumeMounts?: [...corev1.#VolumeMount]

	deploymentLabels?: #Labels
	deploymentAnnotations?: #Annotations
	podLabels?: #Labels
	podAnnotations?: #Annotations
	serviceLabels?: #Labels
	serviceAnnotations?: #Annotations

	nodeSelector: #Labels & {"kubernetes.io/os": "linux"}

	// Optional DNS settings, useful if you have a public and private DNS zone for
	// the same domain on Route 53. What follows is an example of ensuring
	// cert-manager can access an ingress or DNS TXT records at all times.
	// NOTE: This requires Kubernetes 1.10 or `CustomPodDNS` feature gate enabled for
	// the cluster to work.
	// podDnsPolicy: "None"
	// podDnsConfig:
	//   nameservers:
	//     - "1.1.1.1"
	//     - "8.8.8.8"

	ingressShim?: {
		defaultIssuerName?: string
		defaultIssuerKind?: *"ClusterIssuer" | "Issuer"
		defaultIssuerGroup?: string
	}

	prometheus: {
		enabled: *true | bool
		servicemonitor: {
			enabled: false | bool
			prometheusInstance: *"default" | string
			targetPort: *9402 | int
			path: *"/metrics" | string
			interval: *"60s" | #Duration
			scrapeTimeout: *"30s" | #Duration
			labels?: #Labels
			annotations?: #Annotations
			honorLabels: false | bool
			endpointAdditionalProperties: {}
		}
	}

	// Use these variables to configure the HTTP_PROXY environment variables
	http_proxy?: string
	https_proxy?: string
	no_proxy?: string







	// Pod
	tolerations?: [ ...corev1.#Toleration]
	affinity?: corev1.#Affinity
	topologySpreadConstraints?: [...corev1.#TopologySpreadConstraint]

	// Test Job
	test: {
		enabled: *false | bool
		image!:  timoniv1.#Image
	}
}

#Duration: string & =~"^[0-9]+(ns|us|µs|ms|s|m|h)$"
#Percent: string & =~"^(1)?([1-9])?([0-9])%$"
#Labels: {[string & =~"^(([A-Za-z0-9][-A-Za-z0-9_./]*)?[A-Za-z0-9])?$" & strings.MaxRunes(63)]: string & =~"^(([A-Za-z0-9][-A-Za-z0-9_.]*)?[A-Za-z0-9])?$" & strings.MaxRunes(63)}
#Annotations: {[string & =~"^(([A-Za-z0-9][-A-Za-z0-9_./]*)?[A-Za-z0-9])?$" & strings.MaxRunes(63)]: string & =~"^(([A-Za-z0-9][-A-Za-z0-9_.]*)?[A-Za-z0-9])?$" & strings.MaxRunes(63)}

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
