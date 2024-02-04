package templates

import (
	"strings"
	corev1 "k8s.io/api/core/v1"
	timoniv1 "timoni.sh/core/v1alpha1"
	cfg "timoni.sh/cert-manager/templates/config"
)

#ServiceAccount: corev1.#ServiceAccount & {
	#config:    cfg.#Config
	#component: string

	#meta: timoniv1.#MetaComponent & {
		#Meta:      #config.metadata
		#Component: strings.ToLower(#component)
	}

	apiVersion:                   "v1"
	kind:                         "ServiceAccount"
	metadata:                     #meta
	automountServiceAccountToken: #config[#component].serviceAccount.automountServiceAccountToken

	if #config.imagePullSecrets != _|_ {
		imagePullSecrets: #config.imagePullSecrets
	}

	if #config[#component].serviceAccount.labels != _|_ {
		metadata: labels: #config[#component].serviceAccount.labels
	}
	if #config[#component].serviceAccount.annotations != _|_ {
		metadata: annotations: #config[#component].serviceAccount.annotations
	}
}

#TestServiceAccount: corev1.#ServiceAccount & {
	#config:    cfg.#Config
	#component: string

	#meta: timoniv1.#MetaComponent & {
		#Meta:      #config.metadata
		#Component: strings.ToLower(#component)
	}

	apiVersion:                   "v1"
	kind:                         "ServiceAccount"
	metadata:                     #meta
	automountServiceAccountToken: #config.test[#component].serviceAccount.automountServiceAccountToken

	if #config.imagePullSecrets != _|_ {
		imagePullSecrets: #config.imagePullSecrets
	}

	if #config.test[#component].serviceAccount.labels != _|_ {
		metadata: labels: #config.test[#component].serviceAccount.labels
	}
	if #config.test[#component].serviceAccount.annotations != _|_ {
		metadata: annotations: #config.test[#component].serviceAccount.annotations
	}
}
