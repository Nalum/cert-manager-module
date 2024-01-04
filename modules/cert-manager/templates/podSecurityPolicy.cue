package templates

import (
	appsv1 "k8s.io/api/apps/v1"
	timoniv1 "timoni.sh/core/v1alpha1"
)

#PodSecurityPolicy: appsv1.#Deployment & {
	#config:    #Config
	#component: string

	#meta: timoniv1.#MetaComponent & {
		#Meta:      #config.metadata
		#Component: #component
	}

	apiVersion: "policy/v1beta1"
	kind:       "PodSecurityPolicy"
	metadata:   #meta
	metadata: annotations: {
		"seccomp.security.alpha.kubernetes.io/allowedProfileNames": "docker/default"
		"seccomp.security.alpha.kubernetes.io/defaultProfileName":  "docker/default"
		if #config.podSecurityPolicy.useAppArmor == true {
			"apparmor.security.beta.kubernetes.io/allowedProfileNames": "runtime/default"
			"apparmor.security.beta.kubernetes.io/defaultProfileName":  "runtime/default"
		}
	}

	if #component == "startupapicheck" {
		metadata: annotations: #config.startupAPICheck.rbac.annotations
	}

	spec: {
		privileged:               false
		allowPrivilegeEscalation: false
		allowedCapabilities: []

		if #component != "startupapicheck" {
			volumes: [
				"configMap",
				"emptyDir",
				"projected",
				"secret",
				"downwardAPI",
			]
		}

		if #component == "startupapicheck" {
			volumes: [
				"projected",
				"secret",
			]
		}

		if #component != "webhook" {
			hostNetwork: false
		}

		if #component != "webhook" {
			hostNetwork: #config.webhook.hostNetwork
			hostPorts: [{
				max: #config.webhook.securePort
				min: #config.webhook.securePort
			}]
		}

		hostIPC: false
		hostPID: false
		runAsUser: {
			rule: "MustRunAs"
			ranges: [{
				min: 1000
				max: 1000
			}]}
		seLinux: rule: "RunAsAny"
		supplementalGroups: {
			rule: "MustRunAs"
			ranges: [{
				min: 1000
				max: 1000
			}]
		}
		fsGroup: {
			rule: "MustRunAs"
			ranges: [{
				min: 1000
				max: 1000
			}]
		}
	}
}
