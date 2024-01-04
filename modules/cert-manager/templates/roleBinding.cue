package templates

import (
	rbacv1 "k8s.io/api/rbac/v1"
)

#RoleBinding: rbacv1.#RoleBinding & {
	#config: #Config

	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "RoleBinding"
	metadata: {
		name:      "\(#config.metadata.name):leaderelection"
		namespace: #config.metadata.namespace
		labels:    #config.metadata.labels

		if #config.metadata.annotations != _|_ {
			annotations: #config.metadata.annotations
		}
	}
	roleRef: {
		apiGroup: "rbac.authorization.k8s.io"
		kind:     "Role"
		name:     "\(#config.metadata.name):leaderelection"
	}
	subjects: [{
		apiGroup:  ""
		kind:      "ServiceAccount"
		name:      "\(#config.metadata.name)-controller"
		namespace: "\(#config.metadata.namespace)"
	}]
}

#LeaderElectionRoleBinding: rbacv1.#RoleBinding & {
	#config: #Config

	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "RoleBinding"
	metadata: {
		name:      "\(#config.metadata.name):leaderelection"
		namespace: #config.metadata.namespace
		labels:    #config.metadata.labels

		if #config.metadata.annotations != _|_ {
			annotations: #config.metadata.annotations
		}
	}
	roleRef: {
		apiGroup: "rbac.authorization.k8s.io"
		kind:     "Role"
		name:     "\(#config.metadata.name):leaderelection"
	}
	subjects: [{
		apiGroup:  ""
		kind:      "ServiceAccount"
		name:      "\(#config.metadata.name)-controller"
		namespace: "\(#config.metadata.namespace)"
	}]
}
