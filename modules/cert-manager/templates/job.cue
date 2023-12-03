package templates

import (
	batchv1 "k8s.io/api/batch/v1"
)

#Job: batchv1.#Job & {
	_config:    #Config
	apiVersion: "v1"
	kind:       "Job"
	metadata:   _config.metadata
}
