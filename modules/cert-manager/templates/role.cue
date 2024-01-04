package templates

import (
	rbacv1 "k8s.io/api/rbac/v1"
)

#Role: rbacv1.#Role & {
	_config: #Config

	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "Role"
	metadata: {
		name:      "\(_config.metadata.name):leaderelection"
		namespace: _config.metadata.namespace
		labels:    _config.metadata.labels

		if _config.metadata.annotations != _|_ {
			annotations: _config.metadata.annotations
		}
	}
	rules: [{
		apiGroups: ["coordination.k8s.io"]
		resources: ["leases"]
		resourceNames: ["cert-manager-controller"]
		verbs: ["get", "update", "patch"]
	}, {
		apiGroups: ["coordination.k8s.io"]
		resources: ["leases"]
		verbs: ["create"]
	}]
}

#LeaderElectionRole: rbacv1.#Role & {
	_config: #Config

	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "Role"
	metadata: {
		name:      "\(_config.metadata.name):leaderelection"
		namespace: _config.metadata.namespace
		labels:    _config.metadata.labels

		if _config.metadata.annotations != _|_ {
			annotations: _config.metadata.annotations
		}
	}
	rules: [{
		apiGroups: ["coordination.k8s.io"]
		resources: ["leases"]
		resourceNames: ["cert-manager-controller"]
		verbs: ["get", "update", "patch"]
	}, {
		apiGroups: ["coordination.k8s.io"]
		resources: ["leases"]
		verbs: ["create"]
	}]
}
