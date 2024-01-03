package templates

import (
	rbacv1 "k8s.io/api/rbac/v1"
	timoniv1 "timoni.sh/core/v1alpha1"
)

#ClusterRoleBinding: rbacv1.#ClusterRoleBinding & {
	_config:    #Config
	_component: string

	_meta: timoniv1.#MetaComponent & {
		#Meta:      _config.metadata
		#Component: _component
	}

	apiVersion: "v1"
	kind:       "ClusterRoleBinding"
	metadata: name:   "\(_meta.name)-psp"
	metadata: labels: _meta.labels

	if _meta.annotations != _|_ {
		metadata: annotations: _meta.annotations
	}

	roleRef: {
		apiGroup: "rbac.authorization.k8s.io"
		kind:     "ClusterRole"
		name:     "\(_meta.name)-psp"
	}
	subjects: [{
		kind:      "ServiceAccount"
		name:      _meta.name
		namespace: _meta.namespace
	}]
}
