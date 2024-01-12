package config

#AppVersion: *"v1.13.2" | string

#Controller: image: {
	repository: *"quay.io/jetstack/cert-manager-controller" | string
	tag:        #AppVersion
	digest:     *"sha256:9c67cf8c92d8693f9b726bec79c2a84d2cebeb217af6947355601dec4acfa966" | string
}

#Webhook: image: {
	repository: *"quay.io/jetstack/cert-manager-webhook" | string
	tag:        #AppVersion
	digest:     *"sha256:0a9470447ebf1d3ff1c172e19268be12dc26125ff83320d456f6826c677c0ed2" | string
}

#CAInjector: image: {
	repository: *"quay.io/jetstack/cert-manager-cainjector" | string
	tag:        #AppVersion
	digest:     *"sha256:858fee0c4af069d0e87c08fd0943f0091434e05f945d222875fc1f3d36c41616" | string
}

#StartupAPICheck: image: {
	repository: *"quay.io/jetstack/cert-manager-ctl" | string
	tag:        #AppVersion
	digest:     *"sha256:4d9fce2c050eaadabedac997d9bd4a003341e9172c3f48fae299d94fa5f03435" | string
}

#ACMESolver: image: {
	repository: *"quay.io/jetstack/cert-manager-acmesolver" | string
	tag:        #AppVersion
	digest:     *"sha256:7057fd605f530ab2198ebdf1cb486818cce20682632be37c90522a09b95271b1" | string
}
