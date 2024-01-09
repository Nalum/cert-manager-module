package templates

import (
	corev1 "k8s.io/api/core/v1"
	timoniv1 "timoni.sh/core/v1alpha1"

	cfg "timoni.sh/cert-manager/templates/config"
)

#Service: corev1.#Service & {
	#config:    cfg.#Config
	#component: string

	#meta: timoniv1.#MetaComponent & {
		#Meta:      #config.metadata
		#Component: #component
	}

	apiVersion: "v1"
	kind:       "Service"
	metadata:   #meta

	if #component == "controller" {
		if #config.controller.serviceLabels != _|_ {
			metadata: labels: #config.controller.serviceLabels
		}
		if #config.controller.serviceAnnotations != _|_ {
			metadata: annotations: #config.controller.serviceAnnotations
		}
		spec: #ServiceSpecController & {
			#main_config:  #config
			#service_meta: #meta
		}
	}

	if #component == "webhook" {
		if #config.webhook.serviceLabels != _|_ {
			metadata: labels: #config.webhook.serviceLabels
		}
		if #config.webhook.serviceAnnotations != _|_ {
			metadata: annotations: #config.webhook.serviceAnnotations
		}
		spec: #ServiceSpecWebhook & {
			#main_config:  #config
			#service_meta: #meta
		}
	}
}

#ServiceSpecController: {
	#main_config:  cfg.#Config
	#service_meta: timoniv1.#MetaComponent

	type: "ClusterIP"
	ports: [{
		protocol:   "TCP"
		port:       9402
		name:       "tcp-prometheus-servicemonitor"
		targetPort: #main_config.controller.prometheus.serviceMonitor.targetPort
	}]
	selector: #service_meta.#LabelSelector
}

#ServiceSpecWebhook: {
	#main_config:  cfg.#Config
	#service_meta: timoniv1.#MetaComponent

	type: #main_config.webhook.serviceType

	if #main_config.webhook.loadBalancerIP != _|_ {
		loadBalancerIP: #main_config.webhook.loadBalancerIP
	}

	ports: [{
		protocol:   "TCP"
		port:       443
		name:       "https"
		targetPort: "https"
	}]
	selector: #service_meta.#LabelSelector
}
