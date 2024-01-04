package templates

import (
	rbacv1 "k8s.io/api/rbac/v1"
)

#RoleBinding: rbacv1.#RoleBinding & {
	_config: #Config

	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "RoleBinding"
	metadata: {
		name:      "\(_config.metadata.name):leaderelection"
		namespace: _config.metadata.namespace
		labels:    _config.metadata.labels

		if _config.metadata.annotations != _|_ {
			annotations: _config.metadata.annotations
		}
	}
	roleRef: {
		apiGroup: "rbac.authorization.k8s.io"
		kind:     "Role"
		name:     "\(_config.metadata.name):leaderelection"
	}
	subjects: [{
		apiGroup:  ""
		kind:      "ServiceAccount"
		name:      "\(_config.metadata.name)-controller"
		namespace: "\(_config.metadata.namespace)"
	}]
}

#LeaderElectionRoleBinding: rbacv1.#RoleBinding & {
	_config: #Config

	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "RoleBinding"
	metadata: {
		name:      "\(_config.metadata.name):leaderelection"
		namespace: _config.metadata.namespace
		labels:    _config.metadata.labels

		if _config.metadata.annotations != _|_ {
			annotations: _config.metadata.annotations
		}
	}
	roleRef: {
		apiGroup: "rbac.authorization.k8s.io"
		kind:     "Role"
		name:     "\(_config.metadata.name):leaderelection"
	}
	subjects: [{
		apiGroup:  ""
		kind:      "ServiceAccount"
		name:      "\(_config.metadata.name)-controller"
		namespace: "\(_config.metadata.namespace)"
	}]
}
