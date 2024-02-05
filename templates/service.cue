package templates

import (
	"strings"
	corev1 "k8s.io/api/core/v1"
	timoniv1 "timoni.sh/core/v1alpha1"

	cfg "timoni.sh/cert-manager/templates/config"
)

#Service: corev1.#Service & {
	#config:    cfg.#Config
	#component: string

	#meta: timoniv1.#MetaComponent & {
		#Meta:      #config.metadata
		#Component: strings.ToLower(#component)
	}

	apiVersion: "v1"
	kind:       "Service"
	metadata:   #meta

	if #config[#component].serviceLabels != _|_ {
		metadata: labels: #config[#component].service.labels
	}
	if #config[#component].serviceAnnotations != _|_ {
		metadata: annotations: #config[#component].service.annotations
	}

	spec: {
		selector: #meta.#LabelSelector
	}
}

#ServiceController: #Service & {
	#config:    cfg.#Config
	#component: "controller"

	spec: {
		type: "ClusterIP"
		ports: [{
			protocol:   "TCP"
			port:       9402
			name:       "tcp-prometheus-servicemonitor"
			targetPort: #config[#component].monitoring.targetPort
		}]
	}
}

#ServiceWebhook: #Service & {
	#config:    cfg.#Config
	#component: "webhook"

	spec: {

		type: #config.webhook.service.type

		if #config.webhook.loadBalancerIP != _|_ {
			loadBalancerIP: #config.webhook.loadBalancerIP
		}
		ports: [{
			protocol:   "TCP"
			port:       443
			name:       "https"
			targetPort: "https"
		}]
	}
}
