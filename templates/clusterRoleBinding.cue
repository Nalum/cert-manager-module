package templates

import (
	"strings"
	rbacv1 "k8s.io/api/rbac/v1"
	timoniv1 "timoni.sh/core/v1alpha1"

	cfg "timoni.sh/cert-manager/templates/config"
)

#ClusterRoleBinding: rbacv1.#ClusterRoleBinding & {
	#config:    cfg.#Config
	#component: string
	#role?:     string

	#meta: timoniv1.#MetaComponent & {
		#Meta:      #config.metadata
		#Component: strings.ToLower(#component)
	}

	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "ClusterRoleBinding"

	if #role != _|_ {
		metadata: name: "\(#meta.name)-\(#role)"
	}

	if #role == _|_ {
		metadata: name: "\(#meta.name)"
	}

	metadata: labels: #meta.labels

	if #meta.annotations != _|_ {
		metadata: annotations: #meta.annotations
	}

	roleRef: {
		apiGroup: "rbac.authorization.k8s.io"
		kind:     "ClusterRole"

		if #role != _|_ {
			name: "\(#meta.name)-\(#role)"
		}

		if #role == _|_ {
			name: "\(#meta.name)"
		}
	}
	subjects: [{
		kind:      "ServiceAccount"
		name:      #meta.name
		namespace: #meta.namespace
	}]
}
