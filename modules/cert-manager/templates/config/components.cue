package config

import (
	corev1 "k8s.io/api/core/v1"
	networkingv1 "k8s.io/api/networking/v1"
	timoniv1 "timoni.sh/core/v1alpha1"
)

#Controller: {
	#Component
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
		defaultIssuerName?:  string
		defaultIssuerKind?:  *"ClusterIssuer" | "Issuer"
		defaultIssuerGroup?: string
	}
}

#Webhook: {
	#Component
	featureGates?:                              string
	hostNetwork:                                *false | bool
	loadBalancerIP?:                            string
	mutatingWebhookConfigurationAnnotations?:   timoniv1.#Annotations
	securePort:                                 *10250 | int
	timeoutSeconds:                             *10 | int
	validatingWebhookConfigurationAnnotations?: timoniv1.#Annotations
	livenessProbe: {}
	readinessProbe: {}
	args: [...string]

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

	// Overrides the mutating webhook and validating webhook so they reach the webhook
	// service using the `url` field instead of a service.
	url: {
		host?: string
	}
}

#CAInjector: {
	#Component
	config?: {[string]: string}

	args: [...string]
}

#StartupAPICheck: {
	#Component
	backoffLimit:    *4 | int
	jobAnnotations?: timoniv1.#Annotations
	rbac: annotations?: timoniv1.#Annotations

	// Timeout for 'kubectl check api' command
	timeout: *"1m" | #Duration
}

#ACMESolver: {
	image!:          timoniv1.#Image
	imagePullPolicy: #ImagePullPolicy
}
