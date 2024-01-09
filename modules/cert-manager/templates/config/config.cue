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
		enabled: *true | bool
		// Aggregate ClusterRoles to Kubernetes default user-facing roles. Ref: https://kubernetes.io/docs/reference/access-authn-authz/rbac/#user-facing-roles
		aggregateClusterRoles: *true | bool
	}

	podSecurityAdmission: {
		mode:  "audit" | "warn" | *"enforce"
		level: "privileged" | "baseline" | *"restricted"
	}

	leaderElection: {
		namespace:      *"kube-system" | string
		leaseDuration?: *"60s" | #Duration
		renewDeadline?: *"40s" | #Duration
		retryPeriod?:   *"15s" | #Duration
	}

	controller: #Controller
	webhook:    #Webhook
	caInjector: #CAInjector
	acmeSolver: #ACMESolver

	test: {
		enabled:         *true | bool
		startupAPICheck: #StartupAPICheck
	}
}

#Duration: string & =~"^[+-]?((\\d+h)?(\\d+m)?(\\d+s)?(\\d+ms)?(\\d+(us|µs))?(\\d+ns)?)$"
#Percent:  string & =~"^(100|[1-9][0-9]?)%$"

#Monitoring: {
	enabled: *false | bool
	serviceMonitor: {
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
	httpProxy!:  string
	httpsProxy!: string
	noProxy!:    string
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
	enabled:         *false | bool
	minAvailable?:   *1 | int | #Percent
	maxUnavailable?: *0 | int | #Percent
}
