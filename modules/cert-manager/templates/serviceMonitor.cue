package templates

import (
	servicemonitorv1 "monitoring.coreos.com/servicemonitor/v1"
	timoniv1 "timoni.sh/core/v1alpha1"
)

#ServiceMonitor: servicemonitorv1.#ServiceMonitor & {
	#config:    #Config
	#component: string

	#meta: timoniv1.#MetaComponent & {
		#Meta:      #config.metadata
		#Component: #component
	}

	apiVersion: "monitoring.coreos.com/v1"
	kind:       "ServiceMonitor"
	metadata:   #meta
	metadata: labels: prometheus: #config.controller.prometheus.serviceMonitor.prometheusInstance

	if #config.controller.prometheus.serviceMonitor.annotations != _|_ {
		metadata: annotations: #config.controller.prometheus.serviceMonitor.annotations
	}

	spec: {
		jobLabel: #config.metadata.name
		selector: matchLabels: #meta.#LabelSelector

		if #config.controller.prometheus.serviceMonitor.namespace != _|_ {
			namespaceSelector: matchNames: [#meta.namespace]
		}

		endpoints: [{
			targetPort:    #config.controller.prometheus.serviceMonitor.targetPort
			path:          #config.controller.prometheus.serviceMonitor.path
			interval:      #config.controller.prometheus.serviceMonitor.interval
			scrapeTimeout: #config.controller.prometheus.serviceMonitor.scrapeTimeout
			honorLabels:   #config.controller.prometheus.serviceMonitor.honorLabels

			if #config.controller.prometheus.serviceMonitor.endpointAdditionalProperties != _|_ {
				for k, v in #config.controller.prometheus.serviceMonitor.endpointAdditionalProperties {
					"\(k)": v
				}
			}
		}]
	}
}
