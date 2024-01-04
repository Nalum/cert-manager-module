package templates

import (
	rbacv1 "k8s.io/api/rbac/v1"
	timoniv1 "timoni.sh/core/v1alpha1"
)

#ClusterRole: rbacv1.#ClusterRole & {
	#config:    #Config
	#component: string

	#meta: timoniv1.#MetaComponent & {
		#Meta:      #config.metadata
		#Component: #component
	}

	apiVersion: "v1"
	kind:       "ClusterRole"
	metadata: name:   "\(#meta.name)-psp"
	metadata: labels: #meta.labels

	if #meta.annotations != _|_ {
		metadata: annotations: #meta.annotations
	}

	rules: [{
		apiGroups: ["policy"]
		resources: ["podsecuritypolicies"]
		verbs: ["use"]
		resourceNames: [#meta.name]
	}]
}
