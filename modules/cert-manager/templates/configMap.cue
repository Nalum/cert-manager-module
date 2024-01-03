package templates

import (
	"encoding/yaml"
	corev1 "k8s.io/api/core/v1"
	timoniv1 "timoni.sh/core/v1alpha1"
)

#ConfigMap: corev1.#ConfigMap & {
	_config:    #Config
	_component: string

	_meta: timoniv1.#MetaComponent & {
		#Meta:      _config.metadata
		#Component: _component
	}

	apiVersion: "v1"
	kind:       "ConfigMap"
	metadata:   _meta

	data: {
		if _component == "controller" {
			"config.yaml": yaml.Marshal(_config.controller.config)
		}

		if _component == "webhook" {
			"config.yaml": yaml.Marshal(_config.webhook.config)
		}
	}
}
