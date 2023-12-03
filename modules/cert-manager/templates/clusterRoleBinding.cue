package templates

import (
	rbacv1 "k8s.io/api/rbac/v1"
)

#ClusterRoleBinding: rbacv1.#ClusterRoleBinding & {
	_config:    #Config
	apiVersion: "v1"
	kind:       "ClusterRoleBinding"
	metadata:   _config.metadata
}
