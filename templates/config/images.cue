package config

#AppVersion: *"v1.13.3" | string

#Controller: image: {
	repository: *"quay.io/jetstack/cert-manager-controller" | string
	tag:        #AppVersion
	digest:     *"sha256:2121d4250f5734ee097df243507d06536fc264140dba3425045a825ef597c79d" | string
}

#Webhook: image: {
	repository: *"quay.io/jetstack/cert-manager-webhook" | string
	tag:        #AppVersion
	digest:     *"sha256:f45b21f770bf4676c732f19e2ef17c34f46ac75873a5e0aa25703d808b2e5566" | string
}

#CAInjector: image: {
	repository: *"quay.io/jetstack/cert-manager-cainjector" | string
	tag:        #AppVersion
	digest:     *"sha256:ac5154525f99bd0872671613741aac1b7dcb9c0df988571a7618155ddb6fabd2" | string
}

#StartupAPICheck: image: {
	repository: *"quay.io/jetstack/cert-manager-ctl" | string
	tag:        #AppVersion
	digest:     *"sha256:d0d12f721e01b19973c989646c96905bfca7a0ea5f7888d5e9b4adabb4fbc56c" | string
}

#ACMESolver: image: {
	repository: *"quay.io/jetstack/cert-manager-acmesolver" | string
	tag:        #AppVersion
	digest:     *"sha256:b1aa36468479fc5ca1a847f9e7cd1dc21978f273d9cec1d4202a632be9d26fad" | string
}
