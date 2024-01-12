package templates

import (
	servicemonitorv1 "monitoring.coreos.com/servicemonitor/v1"
	timoniv1 "timoni.sh/core/v1alpha1"

	cfg "timoni.sh/cert-manager/templates/config"
)

#ServiceMonitor: servicemonitorv1.#ServiceMonitor & {
	#config:    cfg.#Config
	#component: string

	#meta: timoniv1.#MetaComponent & {
		#Meta:      #config.metadata
		#Component: #component
	}

	metadata: #meta
	metadata: labels: prometheus: #config.controller.monitoring.serviceMonitor.prometheusInstance

	if #config.controller.monitoring.serviceMonitor.annotations != _|_ {
		metadata: annotations: #config.controller.monitoring.serviceMonitor.annotations
	}

	spec: {
		jobLabel: #config.metadata.name
		selector: matchLabels: #meta.#LabelSelector

		if #config.controller.monitoring.serviceMonitor.namespace != _|_ {
			namespaceSelector: matchNames: [#meta.namespace]
		}

		endpoints: [{
			targetPort:    #config.controller.monitoring.serviceMonitor.targetPort
			path:          #config.controller.monitoring.serviceMonitor.path
			interval:      #config.controller.monitoring.serviceMonitor.interval
			scrapeTimeout: #config.controller.monitoring.serviceMonitor.scrapeTimeout
			honorLabels:   #config.controller.monitoring.serviceMonitor.honorLabels

			if #config.controller.monitoring.serviceMonitor.endpointAdditionalProperties != _|_ {
				for k, v in #config.controller.monitoring.serviceMonitor.endpointAdditionalProperties {
					"\(k)": v
				}
			}
		}]
	}
}
