package templates

import (
	"strings"
	rbacv1 "k8s.io/api/rbac/v1"
	timoniv1 "timoni.sh/core/v1alpha1"

	cfg "timoni.sh/cert-manager/templates/config"
)

#RoleBinding: rbacv1.#RoleBinding & {
	#config:     cfg.#Config
	#component:  string
	#roleSuffix: string
	#namespace?: string

	#meta: timoniv1.#MetaComponent & {
		#Meta:      #config.metadata
		#Component: strings.ToLower(#component)
	}

	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "RoleBinding"

	metadata: {
		name:      "\(#meta.name):\(#roleSuffix)"
		namespace: *#namespace | #config.metadata.namespace
		labels:    #meta.labels
		if #config.metadata.annotations != _|_ {
			annotations: #config.metadata.annotations
		}
	}
	roleRef: {
		apiGroup: "rbac.authorization.k8s.io"
		kind:     "Role"
		name:     "\(#meta.name):\(#roleSuffix)"
	}
	subjects: [{
		apiGroup:  ""
		kind:      "ServiceAccount"
		name:      #meta.name
		namespace: #meta.namespace
	}]
}

#ControllerRoleBinding: #RoleBinding & {
	#config:     cfg.#Config
	#component:  "controller"
	#roleSuffix: "leaderelection"
	#namespace:  #config.leaderElection.namespace
}

#CaInjectorRoleBinding: #RoleBinding & {
	#config:     cfg.#Config
	#component:  "caInjector"
	#roleSuffix: "leaderelection"
	#namespace:  #config.leaderElection.namespace
}

#StartupApiCheckRoleBinding: #RoleBinding & {
	#config:     cfg.#Config
	#component:  "startupapicheck"
	#roleSuffix: "create-cert"
}

#WebhookRoleBinding: #RoleBinding & {
	#config:     cfg.#Config
	#component:  "webhook"
	#roleSuffix: "dynamic-serving"
}
