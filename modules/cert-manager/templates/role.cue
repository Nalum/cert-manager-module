package templates

import (
	rbacv1 "k8s.io/api/rbac/v1"
)

#Role: rbacv1.#Role & {
	_config:    #Config
	apiVersion: "v1"
	kind:       "Role"
	metadata:   _config.metadata
}
