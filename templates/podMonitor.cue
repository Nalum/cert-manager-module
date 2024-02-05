package templates

import (
	podmonitorv1 "monitoring.coreos.com/podmonitor/v1"
	timoniv1 "timoni.sh/core/v1alpha1"

	cfg "timoni.sh/cert-manager/templates/config"
)

#PodMonitor: podmonitorv1.#PodMonitor & {
	#config:    cfg.#Config
	#component: string

	#meta: timoniv1.#MetaComponent & {
		#Meta:      #config.metadata
		#Component: #component
	}

	metadata: #meta
	metadata: labels: prometheus: #config.controller.monitoring.prometheusInstance

	if #config.controller.monitoring.annotations != _|_ {
		metadata: annotations: #config.controller.monitoring.annotations
	}

	spec: {
		jobLabel: #config.metadata.name
		selector: matchLabels: #meta.#LabelSelector
		namespaceSelector: matchNames: [#config.controller.monitoring.namespace]

		podMetricsEndpoints: [{
			port:          #config.controller.monitoring.targetPort
			path:          #config.controller.monitoring.path
			interval:      #config.controller.monitoring.interval
			scrapeTimeout: #config.controller.monitoring.scrapeTimeout
			honorLabels:   #config.controller.monitoring.honorLabels

			if #config.controller.monitoring.endpointAdditionalProperties != _|_ {
				for k, v in #config.controller.monitoring.endpointAdditionalProperties {
					"\(k)": v
				}
			}
		}]
	}
}
