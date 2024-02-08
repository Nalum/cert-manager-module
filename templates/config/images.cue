package config

#AppVersion: *"v1.14.2" | string

#Controller: image: {
	repository: *"quay.io/jetstack/cert-manager-controller" | string
	tag:        #AppVersion
	digest:     *"sha256:94c24f76822cbf523eedb36c4c4aaa1eb8fffad31841a82946a175c74e3a9673" | string
}

#Webhook: image: {
	repository: *"quay.io/jetstack/cert-manager-webhook" | string
	tag:        #AppVersion
	digest:     *"sha256:8c2974322be244119eff2112ce1ea935dcd15bc9cc50b42c6796f8d66d09f9e3" | string
}

#CAInjector: image: {
	repository: *"quay.io/jetstack/cert-manager-cainjector" | string
	tag:        #AppVersion
	digest:     *"sha256:20878790620de378a206d74f23e472f99b33fa79f07f744d1de22807ede9c9ce" | string
}

#StartupAPICheck: image: {
	repository: *"quay.io/jetstack/cert-manager-ctl" | string
	tag:        #AppVersion
	digest:     *"sha256:de4ee13b1f85907d569136553bd1f5245a7c44f6b28c5622d2bc2b83e0576474" | string
}

#ACMESolver: image: {
	repository: *"quay.io/jetstack/cert-manager-acmesolver" | string
	tag:        #AppVersion
	digest:     *"sha256:958f9455bfa57dc7b289fc0d32f01d952b8b028a3dbe54300fb4dc633e109fa2" | string
}
