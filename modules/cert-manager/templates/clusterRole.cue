package templates

import (
	rbacv1 "k8s.io/api/rbac/v1"
	timoniv1 "timoni.sh/core/v1alpha1"
)

#ClusterRole: rbacv1.#ClusterRole & {
	_config:    #Config
	_component: string

	_meta: timoniv1.#MetaComponent & {
		#Meta:      _config.metadata
		#Component: _component
	}

	apiVersion: "v1"
	kind:       "ClusterRole"
	metadata: name:   "\(_meta.name)-psp"
	metadata: labels: _meta.labels

	if _meta.annotations != _|_ {
		metadata: annotations: _meta.annotations
	}

	rules: [{
		apiGroups: ["policy"]
		resources: ["podsecuritypolicies"]
		verbs: ["use"]
		resourceNames: [_meta.name]
	}]
}
