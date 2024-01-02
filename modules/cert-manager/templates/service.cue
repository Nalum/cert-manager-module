package templates

import (
	corev1 "k8s.io/api/core/v1"
	timoniv1 "timoni.sh/core/v1alpha1"
)

#Service: corev1.#Service & {
	_config:    #Config
	_component: string

	_meta: timoniv1.#MetaComponent & {
		#Meta:      _config.metadata
		#Component: _component
	}

	apiVersion: "v1"
	kind:       "Service"
	metadata:   _meta

	if _component == "controller" {
		if _config.controller.serviceLabels != _|_ {
			metadata: labels: _config.controller.serviceLabels
		}
		if _config.controller.serviceAnnotations != _|_ {
			metadata: annotations: _config.controller.serviceAnnotations
		}
		spec: #ServiceSpecController & {
			_main_config:  _config
			_service_meta: _meta
		}
	}

	if _component == "webhook" {
		if _config.webhook.serviceLabels != _|_ {
			metadata: labels: _config.webhook.serviceLabels
		}
		if _config.webhook.serviceAnnotations != _|_ {
			metadata: annotations: _config.webhook.serviceAnnotations
		}
		spec: #ServiceSpecWebhook & {
			_main_config:  _config
			_service_meta: _meta
		}
	}
}

#ServiceSpecController: {
	_main_config:  #Config
	_service_meta: timoniv1.#MetaComponent

	type: "ClusterIP"
	ports: [{
		protocol:   "TCP"
		port:       9402
		name:       "tcp-prometheus-servicemonitor"
		targetPort: "{{ _main_config.prometheus.servicemonitor.targetPort }}"
	}]
	selector: _service_meta.#LabelSelector
}

#ServiceSpecWebhook: {
	_main_config:  #Config
	_service_meta: timoniv1.#MetaComponent

	type: _main_config.webhook.serviceType

	if _main_config.webhook.loadBalancerIP != _|_ {
		loadBalancerIP: _main_config.webhook.loadBalancerIP
	}

	ports: [{
		protocol:   "TCP"
		port:       443
		name:       "https"
		targetPort: "https"
	}]
	selector: _service_meta.#LabelSelector
}
