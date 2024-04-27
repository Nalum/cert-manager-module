package config

#AppVersion: *"v1.14.5" | string

#Controller: image: {
	repository: *"quay.io/jetstack/cert-manager-controller" | string
	tag:        #AppVersion
	digest:     *"sha256:9c0527cab629b61bd60c20f0c25615a8593314d3504add968b42bc5b891b253a" | string
}

#Webhook: image: {
	repository: *"quay.io/jetstack/cert-manager-webhook" | string
	tag:        #AppVersion
	digest:     *"sha256:ef419261a209c5409fb1539dbd45c805d05936e955b4530b8ec4ac780577f151" | string
}

#CAInjector: image: {
	repository: *"quay.io/jetstack/cert-manager-cainjector" | string
	tag:        #AppVersion
	digest:     *"sha256:4ffda7facb4da16dab20a88e7607b75ebdab4e6c9069a840216a89f47261ee0b" | string
}

#StartupAPICheck: image: {
	repository: *"quay.io/jetstack/cert-manager-ctl" | string
	tag:        #AppVersion
	digest:     *"sha256:2ddf50d0961658812b8bc89789ec955a1ffd38b601891fb6b09276d5741299c5" | string
}

#ACMESolver: image: {
	repository: *"quay.io/jetstack/cert-manager-acmesolver" | string
	tag:        #AppVersion
	digest:     *"sha256:5e807851354e51b6d978dde72523952464ecc3e79678a88892d2598c7bba9fd5" | string
}
