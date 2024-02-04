package config

import (
	corev1 "k8s.io/api/core/v1"
	networkingv1 "k8s.io/api/networking/v1"
	timoniv1 "timoni.sh/core/v1alpha1"
)

#Controller: {
	#Component

	// Override the namespace used to store DNS provider credentials etc. for ClusterIssuer
	// resources. By default, the same namespace as cert-manager is deployed within is
	// used. This namespace will not be automatically created by the Helm chart.
	clusterResourceNamespace?: string
	// Comma separated string with host and port of the recursive nameservers cert-manager should query
	dns01RecursiveNameservers?: string
	// Forces cert-manager to only use the recursive nameservers for verification.
	// Enabling this option could cause the DNS01 self check to take longer due to caching performed by the recursive nameservers
	dns01RecursiveNameserversOnly: *false | bool
	// When this flag is enabled, secrets will be automatically removed when the certificate resource is deleted
	enableCertificateOwnerRef: *false | bool
	// Comma separated list of feature gates that should be enabled on the controller pod.
	featureGates?: string
	// The maximum number of challenges that can be scheduled as 'processing' at once
	maxConcurrentChallenges: *60 | int
	// Optional DNS settings, useful if you have a public and private DNS zone for
	// the same domain on Route 53. What follows is an example of ensuring
	// cert-manager can access an ingress or DNS TXT records at all times.
	// NOTE: This requires Kubernetes 1.10 or `CustomPodDNS` feature gate enabled for
	// the cluster to work.
	podDNSConfig?: corev1.#PodDNSConfig
	podDNSPolicy:  *"ClusterFirst" | "Default" | "ClusterFirstWithHostNet" | "None"
	monitoring:    #Monitoring

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
		featureGates?: {
			AdditionalCertificateOutputFormats:               *true | bool
			ExperimentalCertificateSigningRequestControllers: *true | bool
			ExperimentalGatewayAPISupport:                    *true | bool
			ServerSideApply:                                  *true | bool
			LiteralCertificateSubject:                        *true | bool
			UseCertificateRequestBasicConstraints:            *true | bool
		}
	}

	ingressShim?: {
		// is the default issuer to use when an Ingress does not specify one
		defaultIssuerName?: string
		// is the default issuer kind to use when an Ingress does not specify one
		defaultIssuerKind?: *"ClusterIssuer" | "Issuer"
		// is the default issuer group to use when an Ingress does not specify one
		defaultIssuerGroup?: string
	}
}

#Webhook: {
	#Component

	// is a comma separated list of feature gates to enable.
	featureGates?: string
	// enalbes host networking for the webhook pod.
	hostNetwork: *false | bool
	// is the IP address to bind to when running the webhook pod.
	loadBalancerIP?: string
	// is a map of annotations to add to the mutating webhook configuration.
	mutatingWebhookConfigurationAnnotations?: timoniv1.#Annotations
	// set the port that the webhook should listen on for requests.
	securePort: *10250 | int
	// number of seconds to wait before timing out a request to the webhook.
	timeoutSeconds: *10 | int
	// is a map of annotations to add to the validating webhook configuration.
	validatingWebhookConfigurationAnnotations?: timoniv1.#Annotations
	// are the arguments to pass to the webhook pod.
	args: [...string]

	// is a map of network policy rules to apply to the webhook pod.
	networkPolicy: networkingv1.#NetworkPolicySpec | *{
		ingress: [{from: [{ipBlock: cidr: "0.0.0.0/0"}]}]
		egress: [
			{
				ports: [
					{port: 80, protocol:   "TCP"},
					{port: 443, protocol:  "TCP"},
					{port: 53, protocol:   "TCP"},
					{port: 53, protocol:   "UDP"},
					{port: 6443, protocol: "TCP"},
				]
				to: [{ipBlock: cidr: "0.0.0.0/0"}]
			},
		]
	}

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

	url: {
		// Overrides the mutating webhook and validating webhook so they reach the webhook
		// service using the `host` field instead of a service.
		host?: string
	}
}

#CAInjector: {
	#Component

	// configures the CAInjector with a custom configmap.
	config?: {[string]: string}
}

#StartupAPICheck: {
	#Component

	// is the number of retries before considering a Job as failed.
	backoffLimit: *4 | int
	// is a map of annotations to add to the job.
	jobAnnotations?: timoniv1.#Annotations
	// Timeout for 'kubectl check api' command
	timeout: *"1m" | #Duration
}

#ACMESolver: {
	image!: timoniv1.#Image
}
