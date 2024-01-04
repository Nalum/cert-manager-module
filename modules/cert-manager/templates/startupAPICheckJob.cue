package templates

import (
	batchv1 "k8s.io/api/batch/v1"
	timoniv1 "timoni.sh/core/v1alpha1"
)

#StartupAPICheckJob: batchv1.#Job & {
	#config: #Config

	#meta: timoniv1.#MetaComponent & {
		#Meta:      #config.metadata
		#Component: "startupapicheck"
	}

	apiVersion: "batch/v1"
	kind:       "Job"
	metadata:   #meta

	if #config.startupAPICheck.jobAnnotations != _|_ {
		metadata: annotations: #config.startupAPICheck.jobAnnotations
	}

	spec: {
		backoffLimit: #config.startupAPICheck.backoffLimit
		template: {
			metadata: {
				labels: #meta.labels

				if #config.startupAPICheck.podLabels != _|_ {
					labels: #config.startupAPICheck.podLabels
				}

				if #config.startupAPICheck.podAnnotations != _|_ {
					annotations: #config.startupAPICheck.podAnnotations
				}
			}

			spec: {
				restartPolicy:      "OnFailure"
				serviceAccountName: #meta.name
				enableServiceLinks: #config.startupAPICheck.enableServiceLinks

				if #config.startupAPICheck.automountServiceAccountToken != _|_ {
					automountServiceAccountToken: #config.startupAPICheck.automountServiceAccountToken
				}

				if #config.priorityClassName != _|_ {
					priorityClassName: #config.priorityClassName
				}

				if #config.startupAPICheck.securityContext != _|_ {
					securityContext: #config.startupAPICheck.securityContext
				}

				containers: [{
					name:            #meta.name
					image:           #config.startupAPICheck.image.reference
					imagePullPolicy: #config.startupAPICheck.imagePullPolicy
					args: [
						"check",
						"api",
						"--wait=\(#config.startupAPICheck.timeout)",
					]
					if #config.startupAPICheck.extraArgs != _|_ {
						args: #config.startupAPICheck.extraArgs
					}

					if #config.startupAPICheck.containerSecurityContext != _|_ {
						securityContext: #config.startupAPICheck.containerSecurityContext
					}

					if #config.startupAPICheck.resources != _|_ {
						resources: #config.startupAPICheck.resources
					}

					if #config.startupAPICheck.volumeMounts != _|_ {
						volumeMounts: #config.startupAPICheck.volumeMounts
					}
				}]

				if #config.startupAPICheck.nodeSelector != _|_ {
					nodeSelector: #config.startupAPICheck.nodeSelector
				}

				if #config.startupAPICheck.affinity != _|_ {
					affinity: #config.startupAPICheck.affinity
				}

				if #config.startupAPICheck.tolerations != _|_ {
					tolerations: #config.startupAPICheck.tolerations
				}

				if #config.startupAPICheck.volumes != _|_ {
					volumes: #config.startupAPICheck.volumes
				}
			}
		}
	}
}
