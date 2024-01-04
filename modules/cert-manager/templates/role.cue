package templates

import (
	rbacv1 "k8s.io/api/rbac/v1"
)

#Role: rbacv1.#Role & {
	#config: #Config

	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "Role"
	metadata: {
		name:      "\(#config.metadata.name):leaderelection"
		namespace: #config.metadata.namespace
		labels:    #config.metadata.labels

		if #config.metadata.annotations != _|_ {
			annotations: #config.metadata.annotations
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
	#config: #Config

	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "Role"
	metadata: {
		name:      "\(#config.metadata.name):leaderelection"
		namespace: #config.metadata.namespace
		labels:    #config.metadata.labels

		if #config.metadata.annotations != _|_ {
			annotations: #config.metadata.annotations
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
