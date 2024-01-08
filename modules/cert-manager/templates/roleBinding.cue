package templates

import (
	rbacv1 "k8s.io/api/rbac/v1"
	timoniv1 "timoni.sh/core/v1alpha1"
)

#RoleBinding: rbacv1.#RoleBinding & {
	#config:    #Config
	#component: string

	#meta: timoniv1.#MetaComponent & {
		#Meta:      #config.metadata
		#Component: #component
	}

	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "RoleBinding"
	metadata: {
		if #component == "controller" || #component == "cainjector" {
			name: "\(#meta.name):leaderelection"
		}

		if #component == "startupapicheck" {
			name: "\(#meta.name):create-cert"
		}

		if #component == "webhook" {
			name: "\(#meta.name):dynamic-serving"
		}

		if #component == "controller" || #component == "cainjector" {
			namespace: #config.leaderElection.namespace
		}

		if #component == "webhook" || #component == "startupapicheck" {
			namespace: #meta.namespace
		}

		labels: #meta.labels

		if #meta.annotations != _|_ {
			annotations: #meta.annotations
		}
	}

	roleRef: {
		apiGroup: "rbac.authorization.k8s.io"
		kind:     "Role"
		if #component == "controller" || #component == "cainjector" {
			name: "\(#meta.name):leaderelection"
		}

		if #component == "webhook" {
			name: "\(#meta.name):dynamic-serving"
		}

		if #component == "startupapicheck" {
			name: "\(#meta.name):create-cert"
		}
	}

	subjects: [{
		apiGroup:  ""
		kind:      "ServiceAccount"
		name:      #meta.name
		namespace: #meta.namespace
	}]
}
