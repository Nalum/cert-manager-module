package templates

import (
	rbacv1 "k8s.io/api/rbac/v1"
)

#RoleBinding: rbacv1.#RoleBinding & {
	_config:    #Config
	apiVersion: "v1"
	kind:       "RoleBinding"
	metadata:   _config.metadata
}
