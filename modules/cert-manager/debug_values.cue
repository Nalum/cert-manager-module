@if(debug)

package main

// Values used by debug_tool.cue.
// Debug example 'cue cmd -t debug -t name=test -t namespace=test -t mv=1.0.0 -t kv=1.28.0 build'.
values: {
	version: "0.1.0"
	test: enabled: false
	metadata: labels: team: "dev"
	installCRDs: true
	config: logging: format:  "json"
	resources: requests: cpu: "100m"
	ingressShim: defaultIssuerName: "dev"

	webhook: {
		networkPolicy: {
			ingress: [
				{
					from: [
						{
							ipBlock: cidr: "0.0.0.0/0"
						},
					]
				},
			]
			egress: [
				{
					ports: [
						{
							port:     80
							protocol: "TCP"
						},
						{
							port:     443
							protocol: "TCP"
						},
						{
							port:     53
							protocol: "TCP"
						},
						{
							port:     53
							protocol: "UDP"
						},
						{
							port:     6443
							protocol: "TCP"
						},
					]
					to: [
						{
							ipBlock: cidr: "0.0.0.0/0"
						},
					]
				},
			]
		}
	}
}
