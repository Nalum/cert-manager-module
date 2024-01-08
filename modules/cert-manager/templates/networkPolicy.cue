package templates

import (
	networkingv1 "k8s.io/api/networking/v1"
	timoniv1 "timoni.sh/core/v1alpha1"
)

#NetworkPolicyAllowEgress: networkingv1.#NetworkPolicy & {
	#config:    #Config
	#component: string

	#meta: timoniv1.#MetaComponent & {
		#Meta:      #config.metadata
		#Component: #component
	}

	apiVersion: "networking.k8s.io/v1"
	kind:       "NetworkPolicy"
	metadata: name:      "\(#meta.name)-allow-egress"
	metadata: namespace: #meta.namespace
	metadata: labels:    #meta.labels

	if #meta.annotations != _|_ {
		metadata: annotations: #meta.annotations
	}

	spec: {
		egress: [
			if #config.webhook.networkPolicy.egress != _|_ {
				for k, v in #config.webhook.networkPolicy.egress {
					v
				}
			},
		]
		podSelector: matchLabels: #meta.#LabelSelector
		policyTypes: ["Egress"]
	}
}

#NetworkPolicyAllowIngress: networkingv1.#NetworkPolicy & {
	#config:    #Config
	#component: string

	#meta: timoniv1.#MetaComponent & {
		#Meta:      #config.metadata
		#Component: #component
	}

	apiVersion: "networking.k8s.io/v1"
	kind:       "NetworkPolicy"
	metadata: name:      "\(#meta.name)-allow-ingress"
	metadata: namespace: #meta.namespace
	metadata: labels:    #meta.labels

	if #meta.annotations != _|_ {
		metadata: annotations: #meta.annotations
	}

	spec: {
		ingress: [
			if #config.webhook.networkPolicy.ingress != _|_ {
				for k, v in #config.webhook.networkPolicy.ingress {
					v
				}
			},
		]
		podSelector: matchLabels: #meta.#LabelSelector
		policyTypes: ["Ingress"]
	}
}
