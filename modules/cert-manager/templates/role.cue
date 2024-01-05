package templates

import (
	rbacv1 "k8s.io/api/rbac/v1"
	timoniv1 "timoni.sh/core/v1alpha1"
)

#Role: rbacv1.#Role & {
	#config:    #Config
	#component: string

	#meta: timoniv1.#MetaComponent & {
		#Meta:      #config.metadata
		#Component: #component
	}

	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "Role"
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

		namespace: #meta.namespace
		labels:    #meta.labels

		if #meta.annotations != _|_ {
			annotations: #meta.annotations
		}
	}

	if #component == "controller" {
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

	if #component == "cainjector" {
		rules: [{
			apiGroups: ["coordination.k8s.io"]
			resources: ["leases"]
			resourceNames: ["cert-manager-cainjector-leader-election", "cert-manager-cainjector-leader-election-core"]
			verbs: ["get", "update", "patch"]
		}, {
			apiGroups: ["coordination.k8s.io"]
			resources: ["leases"]
			verbs: ["create"]
		}]
	}

	if #component == "webhook" {
		rules: [{
			apiGroups: [""]
			resources: ["secrets"]
			resourceNames: [
				"\(#meta.name)-ca",
			]
			verbs: ["get", "list", "watch", "update"]
		}, {
			apiGroups: [""]
			resources: ["secrets"]
			verbs: ["create"]
		}]
	}

	if #component == "startupapicheck" {
		rules: [{
			apiGroups: ["cert-manager.io"]
			resources: ["certificates"]
			verbs: ["create"]
		}]
	}
}
