package templates

import (
	policyv1 "k8s.io/api/policy/v1"
)

#PodDisruptionBudget: policyv1.#PodDisruptionBudget & {
	_config:    #Config
	apiVersion: "v1"
	kind:       "PodDisruptionBudget"
	metadata:   _config.metadata
}
