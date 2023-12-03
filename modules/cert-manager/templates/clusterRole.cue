package templates

import (
	rbacv1 "k8s.io/api/rbac/v1"
)

#ClusterRole: rbacv1.#ClusterRole & {
	_config:    #Config
	apiVersion: "v1"
	kind:       "ClusterRole"
	metadata:   _config.metadata
}
