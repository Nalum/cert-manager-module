package templates

import (
	"strings"

	corev1 "k8s.io/api/core/v1"
	networkingv1 "k8s.io/api/networking/v1"
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
		enabled:     *false | bool
		useAppArmor: *true | bool
	}

	// Logging verbosity
	logLevel: *2 | int & >=0 & <=6

	// Reference to one or more secrets to be used when pulling images
	// ref: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
	imagePullSecrets?: [...corev1.LocalObjectReference]

	// Optional priority class to be used for the cert-manager pods
	priorityClassName: string

	// Setup the Cluster RBAC roles and bindings
	rbac: {
		create: *true | bool
		// Aggregate ClusterRoles to Kubernetes default user-facing roles. Ref: https://kubernetes.io/docs/reference/access-authn-authz/rbac/#user-facing-roles
		aggregateClusterRoles: *true | bool
	}

	leaderElection: {
		namespace:     *"kube-system" | string
		leaseDuration: *"60s" | #Duration
		renewDeadline: *"40s" | #Duration
		retryPeriod:   *"15s" | #Duration
	}

	installCRDs: *false | bool

	replicaCount: *1 | int

	strategy?: corev1.#DeploymentStrategy

	podDisruptionBudget: {
		enabled:        *false | bool
		minAvailable:   *1 | int | #Percent
		maxUnavailable: *1 | int | #Percent
	}

	// Comma separated list of feature gates that should be enabled on the controller pod.
	featureGates?: string

	// The maximum number of challenges that can be scheduled as 'processing' at once
	maxConcurrentChallenges: *60 | int

	image!:          timoniv1.#Image & {repository: "quay.io/jetstack/cert-manager-controller", tag: "v1.13.2"}
	imagePullPolicy: *"IfNotPresent" | "Always" | "Never"

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
		name?: string
		// Optional additional annotations to add to the controller's ServiceAccount
		annotations?: #Annotations
		// Automount API credentials for a Service Account.
		automountServiceAccountToken: *true | bool
		// Optional additional labels to add to the controller's ServiceAccount
		labels?: #Labels
	}

	// Automounting API credentials for a particular pod
	automountServiceAccountToken: *true | bool

	// When this flag is enabled, secrets will be automatically removed when the certificate resource is deleted
	enableCertificateOwnerRef: *false | bool

	// Used to configure options for the controller pod.
	// This allows setting options that'd usually be provided via flags.
	// An APIVersion and Kind must be specified in your values.yaml file.
	// Flags will override options that are set here.
	config: {// TODO: Grab this from the Cert Manager repo instead of defining here
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
	// Use this flag to enable or disable arbitrary controllers, for example, disable the CertificiateRequests approver
	// --controllers=*,-certificaterequests-approver

	extraEnv: [...corev1.EnvVar]

	resources?:       corev1.#ResourceRequirements & {requests: {cpu: *"10m" | string, memory:            *"32Mi" | string}}
	securityContext?: corev1.#SecurityContext & {runAsNonRoot:        *true | bool, seccompProfile: type: *"RuntimeDefault" | string}

	// Container Security Context to be set on the controller component container
	// ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
	containerSecurityContext?: corev1.#ContainerSecurityContext & {allowPrivilegeEscalation: false, capabilities: {drop: ["ALL"], readOnlyRootFilesystem: true, runAsNonRoot: true}}

	volumes?: [...corev1.#Volume]
	volumeMounts?: [...corev1.#VolumeMount]

	deploymentLabels?:      #Labels
	deploymentAnnotations?: #Annotations
	podLabels?:             #Labels
	podAnnotations?:        #Annotations
	serviceLabels?:         #Labels
	serviceAnnotations?:    #Annotations
	tolerations?: [ ...corev1.#Toleration]
	affinity?:    corev1.#Affinity
	nodeSelector: #Labels & {"kubernetes.io/os": "linux"}
	topologySpreadConstraints?: [...corev1.#TopologySpreadConstraint]

	// Optional DNS settings, useful if you have a public and private DNS zone for
	// the same domain on Route 53. What follows is an example of ensuring
	// cert-manager can access an ingress or DNS TXT records at all times.
	// NOTE: This requires Kubernetes 1.10 or `CustomPodDNS` feature gate enabled for
	// the cluster to work.
	podDNSPolicy:  *"ClusterFirst" | "Default" | "ClusterFirstWithHostNet" | "None"
	podDNSConfig?: corev1.#PodDNSConfig

	ingressShim?: {
		defaultIssuerName?:  string
		defaultIssuerKind?:  *"ClusterIssuer" | "Issuer"
		defaultIssuerGroup?: string
	}

	prometheus: {
		enabled: *true | bool
		servicemonitor: {
			enabled:            *false | bool
			prometheusInstance: *"default" | string
			targetPort:         *9402 | int
			path:               *"/metrics" | string
			interval:           *"60s" | #Duration
			scrapeTimeout:      *"30s" | #Duration
			labels?:            #Labels
			annotations?:       #Annotations
			honorLabels:        *false | bool
			endpointAdditionalProperties: {[ string]: string}
		}
	}

	// Use these variables to configure the HTTP_PROXY environment variables
	http_proxy?:  string
	https_proxy?: string
	no_proxy?:    string

	// LivenessProbe settings for the controller container of the controller Pod.
	//
	// Disabled by default, because the controller has a leader election mechanism
	// which should cause it to exit if it is unable to renew its leader election
	// record.
	// LivenessProbe durations and thresholds are based on those used for the Kubernetes
	// controller-manager. See:
	// https://github.com/kubernetes/kubernetes/blob/806b30170c61a38fedd54cc9ede4cd6275a1ad3b/cmd/kubeadm/app/util/staticpod/utils.go#L241-L245
	livenessProbe: {
		enabled: *false | bool
		probe:   corev1.#Probe & {initialDelaySeconds: 10, timeoutSeconds: 15, failureThreshold: 8}
	}

	// enableServiceLinks indicates whether information about services should be
	// injected into pod's environment variables, matching the syntax of Docker
	// links.
	enableServiceLinks: *false | bool

	webhook: {
		replicaCount:   *1 | int
		timeoutSeconds: *10 | int

		// Used to configure options for the webhook pod.
		// This allows setting options that'd usually be provided via flags.
		// An APIVersion and Kind must be specified in your values.yaml file.
		// Flags will override options that are set here.
		config: {
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

		strategy?: corev1.#DeploymentStrategy

		// Pod Security Context to be set on the webhook component Pod
		// ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
		securityContext?: corev1.#SecurityContext & {runAsNonRoot: true, seccompProfile: type: "RuntimeDefault"}

		podDisruptionBudget: {
			enabled:        *false | bool
			minAvailable:   *1 | int | #Percent
			maxUnavailable: *1 | int | #Percent
		}

		// Container Security Context to be set on the webhook component container
		// ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
		containerSecurityContext?: corev1.#ContainerSecurityContext & {allowPrivilegeEscalation: false, capabilities: {drop: ["ALL"], readOnlyRootFilesystem: true, runAsNonRoot: true}}

		// Optional additional annotations to add to the webhook resources
		deploymentAnnotations?:                     #Annotations
		podAnnotations?:                            #Annotations
		serviceAnnotations?:                        #Annotations
		mutatingWebhookConfigurationAnnotations?:   #Annotations
		validatingWebhookConfigurationAnnotations?: #Annotations

		// Optional additional labels to add to the Webhook resources
		podLabels?:     #Labels
		serviceLabels?: #Labels

		// Additional command line flags to pass to cert-manager webhook binary.
		// To see all available flags run docker run quay.io/jetstack/cert-manager-webhook:<version> --help
		extraArgs?: [...string]
		// Path to a file containing a WebhookConfiguration object used to configure the webhook
		// --config=<path-to-config-file>

		// Comma separated list of feature gates that should be enabled on the webhook pod.
		featureGates?: string

		resources?: corev1.#ResourceRequirements & {requests: {cpu: "10m", memory: "32Mi"}}

		// Liveness and readiness probe values
		// Ref: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-probes
		//
		livenessProbe?:  corev1.#Probe & {failureThreshold: 3, initialDelaySeconds: 60, periodSeconds: 10, successThreshold: 1, timeoutSeconds: 1}
		readinessProbe?: corev1.#Probe & {failureThreshold: 3, initialDelaySeconds: 5, periodSeconds:  5, successThreshold:  1, timeoutSeconds: 1}

		nodeSelector: #Labels & {"kubernetes.io/os": "linux"}
		affinity?:    corev1.#Affinity
		tolerations?: [ ...corev1.#Toleration]
		topologySpreadConstraints?: [...corev1.#TopologySpreadConstraint]

		image!:          timoniv1.#Image & {repository: "quay.io/jetstack/cert-manager-webhook", tag: "v1.13.2"}
		imagePullPolicy: *"IfNotPresent" | "Always" | "Never"

		serviceAccount: {
			// Specifies whether a service account should be created
			create: *true | bool
			// The name of the service account to use.
			// If not set and create is true, a name is generated using the fullname template
			name?: string
			// Optional additional annotations to add to the controller's ServiceAccount
			annotations?: #Annotations
			// Optional additional labels to add to the webhook's ServiceAccount
			labels?: #Labels
			// Automount API credentials for a Service Account.
			automountServiceAccountToken: *true | bool
		}

		// Automounting API credentials for a particular pod
		automountServiceAccountToken: *true | bool

		// The port that the webhook should listen on for requests.
		// In GKE private clusters, by default kubernetes apiservers are allowed to
		// talk to the cluster nodes only on 443 and 10250. so configuring
		// securePort: 10250, will work out of the box without needing to add firewall
		// rules or requiring NET_BIND_SERVICE capabilities to bind port numbers <1000
		securePort: *10250 | int

		// Specifies if the webhook should be started in hostNetwork mode.
		//
		// Required for use in some managed kubernetes clusters (such as AWS EKS) with custom
		// CNI (such as calico), because control-plane managed by AWS cannot communicate
		// with pods' IP CIDR and admission webhooks are not working
		//
		// Since the default port for the webhook conflicts with kubelet on the host
		// network, `webhook.securePort` should be changed to an available port if
		// running in hostNetwork mode.
		hostNetwork: *false | bool

		// Specifies how the service should be handled. Useful if you want to expose the
		// webhook to outside of the cluster. In some cases, the control plane cannot
		// reach internal services.
		serviceType:     *"ClusterIP" | "NodePort" | "LoadBalancer" | "ExternalName"
		loadBalancerIP?: string

		// Overrides the mutating webhook and validating webhook so they reach the webhook
		// service using the `url` field instead of a service.
		url?:  string
		host?: string

		// Enables default network policies for webhooks.
		networkPolicy: {
			enabled: *false | bool
			spec?:   networkingv1.#NetworkPolicySpec
		}

		volumes?: [...corev1.#Volume]
		volumeMounts?: [...corev1.#VolumeMount]

		// enableServiceLinks indicates whether information about services should be
		// injected into pod's environment variables, matching the syntax of Docker
		// links.
		enableServiceLinks: *false | bool
	}

	caInjector: {
		enabled:      *true | bool
		replicaCount: *1 | int

		strategy?: corev1.#DeploymentStrategy

		// Pod Security Context to be set on the cainjector component Pod
		// ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
		securityContext?: corev1.#SecurityContext & {runAsNonRoot: true, seccompProfile: type: "RuntimeDefault"}

		podDisruptionBudget: {
			enabled:        *false | bool
			minAvailable:   *1 | int | #Percent
			maxUnavailable: *1 | int | #Percent
		}

		// Container Security Context to be set on the cainjector component container
		// ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
		containerSecurityContext?: corev1.#ContainerSecurityContext & {allowPrivilegeEscalation: false, capabilities: {drop: ["ALL"], readOnlyRootFilesystem: true, runAsNonRoot: true}}

		// Optional additional annotations to add to the webhook resources
		deploymentAnnotations?: #Annotations
		podAnnotations?:        #Annotations

		// Additional command line flags to pass to cert-manager cainjector binary.
		// To see all available flags run docker run quay.io/jetstack/cert-manager-cainjector:<version> --help
		extraArgs?: [...string]
		// Enable profiling for cainjector
		// - --enable-profiling=true

		resources?:   corev1.#ResourceRequirements & {requests: {cpu: "10m", memory: "32Mi"}}
		nodeSelector: #Labels & {"kubernetes.io/os":                  "linux"}
		affinity?:    corev1.#Affinity
		tolerations?: [ ...corev1.#Toleration]
		topologySpreadConstraints?: [...corev1.#TopologySpreadConstraint]

		// Optional additional labels to add to the CA Injector Pods
		podLabels?: #Labels

		image!:          timoniv1.#Image & {repository: "quay.io/jetstack/cert-manager-cainjector", tag: "v1.13.2"}
		imagePullPolicy: *"IfNotPresent" | "Always" | "Never"

		serviceAccount: {
			// Specifies whether a service account should be created
			create: *true | bool
			// The name of the service account to use.
			// If not set and create is true, a name is generated using the fullname template
			name?: string
			// Optional additional annotations to add to the controller's ServiceAccount
			annotations?: #Annotations
			// Optional additional labels to add to the webhook's ServiceAccount
			labels?: #Labels
			// Automount API credentials for a Service Account.
			automountServiceAccountToken: *true | bool
		}

		// Automounting API credentials for a particular pod
		automountServiceAccountToken: *true | bool

		volumes?: [...corev1.#Volume]
		volumeMounts?: [...corev1.#VolumeMount]

		// enableServiceLinks indicates whether information about services should be
		// injected into pod's environment variables, matching the syntax of Docker
		// links.
		enableServiceLinks: *false | bool
	}

	acmeSolver: {
		image!:          timoniv1.#Image & {repository: "quay.io/jetstack/cert-manager-acmesolver", tag: "v1.13.2"}
		imagePullPolicy: *"IfNotPresent" | "Always" | "Never"
	}

	// TODO: turn this into a Timoni Test
	// This startupapicheck is a Helm post-install hook that waits for the webhook
	// endpoints to become available.
	// The check is implemented using a Kubernetes Job- if you are injecting mesh
	// sidecar proxies into cert-manager pods, you probably want to ensure that they
	// are not injected into this Job's pod. Otherwise the installation may time out
	// due to the Job never being completed because the sidecar proxy does not exit.
	// See https://github.com/cert-manager/cert-manager/pull/4414 for context.
	startupAPICheck: {
		enabled: *true | bool

		// Pod Security Context to be set on the startupapicheck component Pod
		// ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
		securityContext?: corev1.#SecurityContext & {runAsNonRoot: true, seccompProfile: type: "RuntimeDefault"}

		// Container Security Context to be set on the controller component container
		// ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
		containerSecurityContext?: corev1.#ContainerSecurityContext & {allowPrivilegeEscalation: false, capabilities: {drop: ["ALL"], readOnlyRootFilesystem: true, runAsNonRoot: true}}

		// Timeout for 'kubectl check api' command
		timeout: *"1m" | #Duration

		// Job backoffLimit
		backoffLimit: *4 | int

		// Optional additional annotations to add to the startupapicheck Job
		jobAnnotations?: #Annotations

		// Optional additional annotations to add to the startupapicheck Pods
		podAnnotations?: #Annotations

		// Additional command line flags to pass to startupapicheck binary.
		// To see all available flags run docker run quay.io/jetstack/cert-manager-ctl:<version> --help
		extraArgs: [...string]

		resources?:   corev1.#ResourceRequirements & {requests: {cpu: "10m", memory: "32Mi"}}
		nodeSelector: #Labels & {"kubernetes.io/os":                  "linux"}
		affinity?:    corev1.#Affinity
		tolerations?: [ ...corev1.#Toleration]

		// Optional additional labels to add to the startupapicheck Pods
		podLabels?: #Labels

		image!:          timoniv1.#Image & {repository: "quay.io/jetstack/cert-manager-ctl", tag: "v1.13.2"}
		imagePullPolicy: *"IfNotPresent" | "Always" | "Never"

		// annotations for the startup API Check job RBAC and PSP resources
		rbac: annotations?: #Annotations

		// Automounting API credentials for a particular pod
		automountServiceAccountToken: *true | bool

		serviceAccount: {
			// Specifies whether a service account should be created
			create: *true | bool

			// The name of the service account to use.
			// If not set and create is true, a name is generated using the fullname template
			name?: string

			// Optional additional annotations to add to the Job's ServiceAccount
			annotations?: #Annotations

			// Automount API credentials for a Service Account.
			automountServiceAccountToken: *true | bool

			// Optional additional labels to add to the startupapicheck's ServiceAccount
			labels?: #Labels
		}

		volumes?: [...corev1.#Volume]
		volumeMounts?: [...corev1.#VolumeMount]

		// enableServiceLinks indicates whether information about services should be
		// injected into pod's environment variables, matching the syntax of Docker
		// links.
		enableServiceLinks: *false | bool
	}

	// Test Job
	test: {
		enabled: *false | bool
		image!:  timoniv1.#Image
	}
}

#Duration: string & =~"^[0-9]+(ns|us|µs|ms|s|m|h)$"
#Percent:  string & =~"^(1)?([1-9])?([0-9])%$"
#Labels: {[string & =~"^(([A-Za-z0-9][-A-Za-z0-9_./]*)?[A-Za-z0-9])?$" & strings.MaxRunes(63)]: string & =~"^(([A-Za-z0-9][-A-Za-z0-9_.]*)?[A-Za-z0-9])?$" & strings.MaxRunes(63)}
#Annotations: {[string & =~"^(([A-Za-z0-9][-A-Za-z0-9_./]*)?[A-Za-z0-9])?$" & strings.MaxRunes(63)]: string & =~"^(([A-Za-z0-9][-A-Za-z0-9_.]*)?[A-Za-z0-9])?$" & strings.MaxRunes(63)}

// Instance takes the config values and outputs the Kubernetes objects.
#Instance: {
	config: #Config

	objects: {
		deployment:               #Deployment & {_config:        config}
		webhookDeployment:        #Deployment & {_config:        config}
		webhookMutatingWebhook:   #MutatingWebhook & {_config:   config}
		webhookValidatingWebhook: #ValidatingWebhook & {_config: config}
		webhookService:           #Service & {_config:           config}
	}

	objects: {
		for name, crd in customresourcedefinition {
			"\(name)": crd
			"\(name)": metadata: labels:      config.metadata.labels
			"\(name)": metadata: annotations: config.metadata.annotations
		}
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
				caInjectorPSPClusterRole:        #ClusterRole & {_config:        config}
				caInjectorPSPClusterRoleBinding: #ClusterRoleBinding & {_config: config}
				caInjectorPSP:                   #PodSecurityPolicy & {_config:  config}
			}
		}

		if config.rbac.create {
			objects: {
				caInjectorClusterRole:        #ClusterRole & {_config:        config}
				caInjectorClusterRoleBinding: #ClusterRoleBinding & {_config: config}
				caInjectorRole:               #Role & {_config:               config}
				caInjectorRoleBinding:        #RoleBinding & {_config:        config}
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
			networkPolicyEgress:   #NetworkPolicy & {_config: config}
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
			pspClusterRole:        #ClusterRole & {_config:        config}
			pspClusterRoleBinding: #ClusterRoleBinding & {_config: config}
			podSecurityPolicy:     #PodSecurityPolicy & {_config:  config}

			webhookPSPClusterRole:        #ClusterRole & {_config:        config}
			webhookPSPClusterRoleBinding: #ClusterRoleBinding & {_config: config}
			webhookPSP:                   #PodSecurityPolicy & {_config:  config}
		}
	}

	if config.rbac.create {
		objects: {
			leaderElectionRole:        #Role & {_config:        config}
			leaderElectionRoleBinding: #RoleBinding & {_config: config}

			clusterViewClusterRole: #ClusterRole & {_config: config}
			viewClusterRole:        #ClusterRole & {_config: config}
			editClusterRole:        #ClusterRole & {_config: config}

			controllerIssuersClusterRole:                           #ClusterRole & {_config:        config}
			controllerClusterIssuersClusterRole:                    #ClusterRole & {_config:        config}
			controllerCertificatesClusterRole:                      #ClusterRole & {_config:        config}
			controllerOrdersClusterRole:                            #ClusterRole & {_config:        config}
			controllerChallengesClusterRole:                        #ClusterRole & {_config:        config}
			controllerIngressShimClusterRole:                       #ClusterRole & {_config:        config}
			controllerApproveClusterRole:                           #ClusterRole & {_config:        config}
			controllerCertificateSigningRequestsClusterRole:        #ClusterRole & {_config:        config}
			controllerIssuersClusterRoleBinding:                    #ClusterRoleBinding & {_config: config}
			controllerClusterIssuersClusterRoleBinding:             #ClusterRoleBinding & {_config: config}
			controllerCertificatesClusterRoleBinding:               #ClusterRoleBinding & {_config: config}
			controllerOrdersClusterRoleBinding:                     #ClusterRoleBinding & {_config: config}
			controllerChallengesClusterRoleBinding:                 #ClusterRoleBinding & {_config: config}
			controllerIngressShimClusterRoleBinding:                #ClusterRoleBinding & {_config: config}
			controllerApproveClusterRoleBinding:                    #ClusterRoleBinding & {_config: config}
			controllerCertificateSigningRequestsClusterRoleBinding: #ClusterRoleBinding & {_config: config}

			webhookRole:               #Role & {_config:               config}
			webhookRoleBinding:        #RoleBinding & {_config:        config}
			webhookClusterRole:        #ClusterRole & {_config:        config}
			webhookClusterRoleBinding: #ClusterRoleBinding & {_config: config}
		}
	}

	if config.prometheus.enabled && config.prometheus.serviceMonitor.enabled {
		objects: {
			service:        #Service & {_config:        config}
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
				startupAPICheckPSPClusterRole:        #ClusterRole & {_config:        config}
				startupAPICheckPSPClusterRoleBinding: #ClusterRoleBinding & {_config: config}
				startupAPICheckPSP:                   #PodSecurityPolicy & {_config:  config}
			}
		}

		if config.rbac.create {
			objects: {
				startupAPICheckRole:        #Role & {_config:        config}
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
