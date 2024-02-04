package templates

import (
	batchv1 "k8s.io/api/batch/v1"
	timoniv1 "timoni.sh/core/v1alpha1"

	cfg "timoni.sh/cert-manager/templates/config"
)

#StartupAPICheckJob: batchv1.#Job & {
	#config: cfg.#Config

	#meta: timoniv1.#MetaComponent & {
		#Meta:      #config.metadata
		#Component: "startupapicheck"
	}

	apiVersion: "batch/v1"
	kind:       "Job"
	metadata:   #meta
	metadata: annotations: timoniv1.Action.Force

	if #config.test.startupAPICheck.jobAnnotations != _|_ {
		metadata: annotations: #config.test.startupAPICheck.jobAnnotations
	}

	spec: {
		backoffLimit: #config.test.startupAPICheck.backoffLimit
		template: {
			metadata: {
				labels: #meta.labels

				if #config.test.startupAPICheck.podLabels != _|_ {
					labels: #config.test.startupAPICheck.podLabels
				}

				if #config.test.startupAPICheck.podAnnotations != _|_ {
					annotations: #config.test.startupAPICheck.podAnnotations
				}
			}

			spec: {
				restartPolicy:                "OnFailure"
				serviceAccountName:           #meta.name
				enableServiceLinks:           #config.test.startupAPICheck.enableServiceLinks
				automountServiceAccountToken: #config.test.startupAPICheck.automountServiceAccountToken
				securityContext:              #config.test.startupAPICheck.securityContext
				nodeSelector:                 #config.test.startupAPICheck.nodeSelector

				if #config.priorityClassName != _|_ {
					priorityClassName: #config.priorityClassName
				}

				containers: [{
					name:            #meta.name
					image:           #config.test.startupAPICheck.image.reference
					imagePullPolicy: #config.test.startupAPICheck.image.pullPolicy
					securityContext: #config.test.startupAPICheck.containerSecurityContext

					args: [
						"check",
						"api",
						"--wait=\(#config.test.startupAPICheck.timeout)",
						for arg in #config.test.startupAPICheck.extraArgs {arg},
					]

					if #config.test.startupAPICheck.resources != _|_ {
						resources: #config.test.startupAPICheck.resources
					}

					if #config.test.startupAPICheck.volumeMounts != _|_ {
						volumeMounts: #config.test.startupAPICheck.volumeMounts
					}
				}]

				if #config.test.startupAPICheck.affinity != _|_ {
					affinity: #config.test.startupAPICheck.affinity
				}

				if #config.test.startupAPICheck.tolerations != _|_ {
					tolerations: #config.test.startupAPICheck.tolerations
				}

				if #config.test.startupAPICheck.volumes != _|_ {
					volumes: #config.test.startupAPICheck.volumes
				}
			}
		}
	}
}
