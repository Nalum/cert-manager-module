package templates

import (
	corev1 "k8s.io/api/core/v1"

	cfg "timoni.sh/cert-manager/templates/config"
)

#Namespace: corev1.#Namespace & {
	#config: cfg.#Config

	apiVersion: "v1"
	kind:       "Namespace"
	metadata: {
		name:   #config.metadata.namespace
		labels: #config.metadata.labels
		labels: "pod-security.kubernetes.io/\(#config.podSecurityAdmission.mode)": #config.podSecurityAdmission.level

		if #config.metadata.annotations != _|_ {
			annotations: #config.metadata.annotations
		}
	}
}
