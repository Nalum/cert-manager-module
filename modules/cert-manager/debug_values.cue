@if(debug)

package main

// Values used by debug_tool.cue.
// Debug example 'cue cmd -t debug -t name=test -t namespace=test -t mv=1.0.0 -t kv=1.28.0 build'.
values: {
	metadata: labels: team:                                  "dev"
	metadata: annotations: "cert-manager.timoni.sh/testing": "true"
	rbac: {
		enabled:               true
		aggregateClusterRoles: false
	}

	controller: {
		config: logging: format:  "json"
		resources: requests: cpu: "100m"
		ingressShim: defaultIssuerName:    "dev"
		monitoring: enabled:               true
		podDisruptionBudget: minAvailable: 1

		strategy: {
			type: "RollingUpdate"
			rollingUpdate: {
				maxSurge: 2
			}
		}
	}

	webhook: {
		podDisruptionBudget: enabled:      true
		podDisruptionBudget: minAvailable: 1
	}

	caInjector: {
		podDisruptionBudget: enabled:      true
		podDisruptionBudget: minAvailable: 1
	}
}
