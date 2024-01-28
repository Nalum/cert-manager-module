package templates

import (
	"strings"
	rbacv1 "k8s.io/api/rbac/v1"
	timoniv1 "timoni.sh/core/v1alpha1"

	cfg "timoni.sh/cert-manager/templates/config"
)

#Role: rbacv1.#Role & {
	#config:     cfg.#Config
	#component:  string
	#roleSuffix: string
	#namespace?: string

	#meta: timoniv1.#MetaComponent & {
		#Meta:      #config.metadata
		#Component: strings.ToLower(#component)
	}
	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "Role"
	metadata: {
		name:      "\(#meta.name):\(#roleSuffix)"
		namespace: *#namespace | #config.metadata.namespace
		labels:    #meta.labels
		if #config.metadata.annotations != _|_ {
			annotations: #config.metadata.annotations
		}
	}
}

#ControllerRole: #Role & {
	#config:     cfg.#Config
	#component:  "controller"
	#roleSuffix: "leaderelection"
	#namespace:  #config.leaderElection.namespace
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

#CaInjectorRole: #Role & {
	#config:     cfg.#Config
	#component:  "caInjector"
	#roleSuffix: "leaderelection"
	#namespace:  #config.leaderElection.namespace
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

#StartupApiCheckRole: #Role & {
	#config:     cfg.#Config
	#component:  "startupAPICheck"
	#roleSuffix: "create-cert"
	rules: [{
		apiGroups: ["cert-manager.io"]
		resources: ["certificates"]
		verbs: ["create"]
	}]
}

#WebhookRole: #Role & {
	#config:     cfg.#Config
	#component:  "webhook"
	#roleSuffix: "dynamic-serving"
	rules: [{
		apiGroups: [""]
		resources: ["secrets"]
		resourceNames: [
			"\(#config.metadata.name)-\(#component)-ca",
		]
		verbs: ["get", "list", "watch", "update"]
	}, {
		apiGroups: [""]
		resources: ["secrets"]
		verbs: ["create"]
	}]
}
