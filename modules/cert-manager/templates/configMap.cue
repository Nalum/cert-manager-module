package templates

import (
	"encoding/yaml"
	corev1 "k8s.io/api/core/v1"
	timoniv1 "timoni.sh/core/v1alpha1"

	cfg "timoni.sh/cert-manager/templates/config"
)

#ConfigMap: corev1.#ConfigMap & {
	#config:    cfg.#Config
	#component: string

	#meta: timoniv1.#MetaComponent & {
		#Meta:      #config.metadata
		#Component: #component
	}

	apiVersion: "v1"
	kind:       "ConfigMap"
	metadata:   #meta

	data: {
		if #component == "controller" {
			"config.yaml": yaml.Marshal(#config.controller.config)
		}

		if #component == "webhook" {
			"config.yaml": yaml.Marshal(#config.webhook.config)
		}
	}
}
