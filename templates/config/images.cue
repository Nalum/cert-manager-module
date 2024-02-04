package config

#AppVersion: *"v1.14.1" | string

#Controller: image: {
	repository: *"quay.io/jetstack/cert-manager-controller" | string
	tag:        #AppVersion
	digest:     *"sha256:3ef9b7e85e89a21c3727f89f6e3f4186853df8de8393e309fa9bcc9a776e69a5" | string
}

#Webhook: image: {
	repository: *"quay.io/jetstack/cert-manager-webhook" | string
	tag:        #AppVersion
	digest:     *"sha256:8a0a0c94a67ef1097db79c26a71a05d4cdbebbb6906a8cab21f4bd15c8ed7c3a" | string
}

#CAInjector: image: {
	repository: *"quay.io/jetstack/cert-manager-cainjector" | string
	tag:        #AppVersion
	digest:     *"sha256:fac683efcd03c95ec61063a80bca257ba24544ab7b233a8574a19ec3a4e8c4aa" | string
}

#StartupAPICheck: image: {
	repository: *"quay.io/jetstack/cert-manager-ctl" | string
	tag:        #AppVersion
	digest:     *"sha256:c15e970af7eb7a51d60d14ed9ea9f9eae0dfbb095a2c4811590cc6bce2d151e7" | string
}

#ACMESolver: image: {
	repository: *"quay.io/jetstack/cert-manager-acmesolver" | string
	tag:        #AppVersion
	digest:     *"sha256:d31555b1727c3f1ba1de456c8f45abf32ad561c7ecfad70ac674dbd9d231e434" | string
}
