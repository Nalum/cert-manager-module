package templates

import (
	rbacv1 "k8s.io/api/rbac/v1"
	timoniv1 "timoni.sh/core/v1alpha1"
)

#ClusterRoleBinding: rbacv1.#ClusterRoleBinding & {
	#config:    #Config
	#component: string

	#meta: timoniv1.#MetaComponent & {
		#Meta:      #config.metadata
		#Component: #component
	}

	apiVersion: "v1"
	kind:       "ClusterRoleBinding"
	metadata: name:   "\(#meta.name)-psp"
	metadata: labels: #meta.labels

	if #meta.annotations != _|_ {
		metadata: annotations: #meta.annotations
	}

	roleRef: {
		apiGroup: "rbac.authorization.k8s.io"
		kind:     "ClusterRole"
		name:     "\(#meta.name)-psp"
	}
	subjects: [{
		kind:      "ServiceAccount"
		name:      #meta.name
		namespace: #meta.namespace
	}]
}
