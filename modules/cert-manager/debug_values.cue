@if(debug)

package main

// Values used by debug_tool.cue.
// Debug example 'cue cmd -t debug -t name=test -t namespace=test -t mv=1.0.0 -t kv=1.28.0 build'.
values: {
	metadata: labels: team:                                     "dev"
	metadata: annotations: "cert-manager.io/timoni.sh/testing": "true"

	controller: {
		config: logging: format:  "json"
		resources: requests: cpu: "100m"
		ingressShim: defaultIssuerName: "dev"
		prometheus: serviceMonitor: {}

		strategy: {
			type: "RollingUpdate"
			rollingUpdate: {
				maxSurge: 2
			}
		}
	}

	webhook: config: {}
}
