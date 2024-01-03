@if(debug)

package main

// Values used by debug_tool.cue.
// Debug example 'cue cmd -t debug -t name=test -t namespace=test -t mv=1.0.0 -t kv=1.28.0 build'.
values: {
	version: "0.1.0-debug"

	metadata: labels: team: "dev"

	controller: config: logging: format:  "json"
	controller: resources: requests: cpu: "100m"
	controller: ingressShim: defaultIssuerName: "dev"

	controller: strategy: {
		type: "RollingUpdate"
		rollingUpdate: {
			maxSurge: 2
		}
	}

	podSecurityPolicy: {}

	controller: prometheus: serviceMonitor: {}

	controller: serviceAccount: {}
	webhook: serviceAccount: {}
	caInjector: serviceAccount: {}
	startupAPICheck: serviceAccount: {}

	webhook: config: {}

	controller: image: {
		repository: "quay.io/jetstack/cert-manager-controller"
		tag:        "v1.13.2"
		digest:     "sha256:9c67cf8c92d8693f9b726bec79c2a84d2cebeb217af6947355601dec4acfa966"
	}

	webhook: image: {
		repository: "quay.io/jetstack/cert-manager-webhook"
		tag:        "v1.13.2"
		digest:     "sha256:0a9470447ebf1d3ff1c172e19268be12dc26125ff83320d456f6826c677c0ed2"
	}

	caInjector: image: {
		repository: "quay.io/jetstack/cert-manager-cainjector"
		tag:        "v1.13.2"
		digest:     "sha256:858fee0c4af069d0e87c08fd0943f0091434e05f945d222875fc1f3d36c41616"
	}

	acmeSolver: image: {
		repository: "quay.io/jetstack/cert-manager-acmesolver"
		tag:        "v1.13.2"
		digest:     "sha256:7057fd605f530ab2198ebdf1cb486818cce20682632be37c90522a09b95271b1"
	}

	startupAPICheck: image: {
		repository: "quay.io/jetstack/cert-manager-ctl"
		tag:        "v1.13.2"
		digest:     "sha256:4d9fce2c050eaadabedac997d9bd4a003341e9172c3f48fae299d94fa5f03435"
	}

	webhook: networkPolicy: {
		ingress: [{from: [{ipBlock: cidr: "0.0.0.0/0"}]}]
		egress: [
			{
				ports: [
					{port: 80, protocol:   "TCP"},
					{port: 443, protocol:  "TCP"},
					{port: 53, protocol:   "TCP"},
					{port: 53, protocol:   "UDP"},
					{port: 6443, protocol: "TCP"},
				]
				to: [{ipBlock: cidr: "0.0.0.0/0"}]
			},
		]
	}
}
