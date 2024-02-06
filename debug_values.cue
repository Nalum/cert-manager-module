@if(debug)

package main

// Values used by debug_tool.cue.
// Debug example 'cue cmd -t debug -t name=test -t namespace=test -t mv=1.0.0 -t kv=1.28.0 build'.
values: {
	metadata: labels: team:                                  "dev"
	metadata: annotations: "cert-manager.timoni.sh/testing": "true"

	highAvailability: enabled: true

	rbac: {
		enabled:               true
		aggregateClusterRoles: false
	}

	controller: {
		config: logging: format:  "json"
		resources: requests: cpu: "100m"
		ingressShim: defaultIssuerName:    "dev"
		monitoring: enabled:               true

		livenessProbe: {
			initialDelaySeconds: 30
			periodSeconds:       15
			failureThreshold:    4
			timeoutSeconds:      2
		}

		strategy: {
			type: "RollingUpdate"
			rollingUpdate: {
				maxSurge: 1
			}
		}
	}

	webhook: {

		livenessProbe: {
			initialDelaySeconds: 30
			periodSeconds:       15
			failureThreshold:    4
			timeoutSeconds:      2
		}

		readinessProbe: {
			initialDelaySeconds: 20
			periodSeconds:       10
			failureThreshold:    6
			timeoutSeconds:      2
		}

		strategy: {
			type: "RollingUpdate"
			rollingUpdate: {
				maxSurge: 1
			}
		}
	}

	caInjector: {
		podDisruptionBudget: minAvailable: 2

		strategy: {
			type: "RollingUpdate"
			rollingUpdate: {
				maxSurge: 1
			}
		}
	}
}
