package config

import (
	corev1 "k8s.io/api/core/v1"
	timoniv1 "timoni.sh/core/v1alpha1"
)

// Config defines the schema and defaults for the Instance values.
#Config: {
	// The kubeVersion is a required field, set at apply-time
	// via timoni.cue by querying the user's Kubernetes API.
	kubeVersion!: string
	// Using the kubeVersion you can enforce a minimum Kubernetes minor version.
	// By default, the minimum Kubernetes version is set to 1.20.
	clusterVersion: timoniv1.#SemVer & {#Version: kubeVersion, #Minimum: "1.27.0"}

	// The moduleVersion is set from the user-supplied module version.
	// This field is used for the `app.kubernetes.io/version` label.
	moduleVersion!: string

	// Metadata (common to all resources)
	metadata: timoniv1.#Metadata & {#Version: moduleVersion}
	metadata: labels: (timoniv1.#StdLabelPartOf): "cert-manager"

	// Reference to one or more secrets to be used when pulling images
	// ref: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
	imagePullSecrets?: [...corev1.#LocalObjectReference]

	// Optional priority class to be used for the cert-manager pods
	priorityClassName?: string

	// Logging verbosity
	logLevel: *2 | int & >=0 & <=6

	// Setup the Cluster RBAC roles and bindings
	rbac: {
		// Create the roles and bindings for cert-manager
		enabled: *true | bool
		// Aggregate ClusterRoles to Kubernetes default user-facing roles. Ref: https://kubernetes.io/docs/reference/access-authn-authz/rbac/#user-facing-roles
		aggregateClusterRoles: *true | bool
	}

	podSecurityAdmission: {
		// Set the PodSecurity admission controller mode for the namespace
		mode: "audit" | "warn" | *"enforce"
		// Set the PodSecurity admission controller level for the namespace
		level: "privileged" | "baseline" | *"restricted"
	}

	highAvailability: {
		// Enable high availability features
		enabled: *false | bool
		// Number of replicas of the cert-manager controller to run
		controllerReplicas: *2 | int
		// Number of replicas of the cert-manager webhook to run
		webhookReplicas: *3 | int
		// Number of replicas of the cert-manager caInjector to run
		caInjectorReplicas: *2 | int
	}

	leaderElection: {
		// Override the namespace used for the leader election lease
		namespace: *"kube-system" | string
		// The duration that non-leader candidates will wait after observing a
		// leadership renewal until attempting to acquire leadership of a led but
		// unrenewed leader slot. This is effectively the maximum duration that a
		// leader can be stopped before it is replaced by another candidate.
		leaseDuration?: #Duration
		// The interval between attempts by the acting master to renew a leadership
		// slot before it stops leading. This must be less than or equal to the
		// lease duration.
		renewDeadline?: #Duration
		// The duration the clients should wait between attempting acquisition and
		// renewal of a leadership.
		retryPeriod?: #Duration
	}

	controller: #Controller
	webhook:    #Webhook
	caInjector: #CAInjector
	acmeSolver: #ACMESolver

	test: {
		// Enable startupAPICheck to verify the cert-manager API is available
		enabled:         *true | bool
		startupAPICheck: #StartupAPICheck
	}
}

#Duration: string & =~"^[+-]?((\\d+h)?(\\d+m)?(\\d+s)?(\\d+ms)?(\\d+(us|µs))?(\\d+ns)?)$"
#Percent:  string & =~"^(100|[1-9][0-9]?)%$"

#Monitoring: {
	// Enable Prometheus monitoring
	enabled: *false | bool
	serviceMonitor: {
		// Enable Prometheus ServiceMonitor monitoring instead of the prometheus shim
		enabled:            *false | bool
		prometheusInstance: *"default" | string
		targetPort:         *"http-metrics" | int | string
		path:               *"/metrics" | string
		interval:           *"60s" | #Duration
		scrapeTimeout:      *"30s" | #Duration
		labels?:            timoniv1.#Labels
		annotations?:       timoniv1.#Annotations
		honorLabels:        *false | bool
		endpointAdditionalProperties?: {[string]: string}
	}
}

#Proxy: {
	// What domains should be proxied through the http proxy
	httpProxy!: string
	// What domains should be proxied through the https proxy
	httpsProxy!: string
	// What domains should not be proxied
	noProxy!: string
}

#SecurityContext: {
	runAsNonRoot: *true | bool
	seccompProfile: type: *"RuntimeDefault" | string
}

#ContainerSecurityContext: corev1.#SecurityContext & {
	allowPrivilegeEscalation: *false | bool
	readOnlyRootFilesystem:   *true | bool
	runAsNonRoot:             *true | bool
	capabilities: corev1.#Capabilities & {
		drop: *["ALL"] | null | [...string]
	}
}

#PodDisruptionBudgetData: {
	enabled:         *true | bool
	minAvailable?:   int | #Percent
	maxUnavailable?: int | #Percent
}
