package templates

import (
	batchv1 "k8s.io/api/batch/v1"
	timoniv1 "timoni.sh/core/v1alpha1"
)

#StartupAPICheckJob: batchv1.#Job & {
	_config: #Config

	_meta: timoniv1.#MetaComponent & {
		#Meta:      _config.metadata
		#Component: "startupapicheck"
	}

	apiVersion: "batch/v1"
	kind:       "Job"
	metadata:   _meta

	if _config.startupAPICheck.jobAnnotations != _|_ {
		metadata: annotations: _config.startupAPICheck.jobAnnotations
	}

	spec: {
		backoffLimit: _config.startupAPICheck.backoffLimit
		template: {
			metadata: {
				labels: _meta.labels

				if _config.startupAPICheck.podLabels != _|_ {
					labels: _config.startupAPICheck.podLabels
				}

				if _config.startupAPICheck.podAnnotations != _|_ {
					annotations: _config.startupAPICheck.podAnnotations
				}
			}

			spec: {
				restartPolicy:      "OnFailure"
				serviceAccountName: _meta.name
				enableServiceLinks: _config.startupAPICheck.enableServiceLinks

				if _config.startupAPICheck.automountServiceAccountToken != _|_ {
					automountServiceAccountToken: _config.startupAPICheck.automountServiceAccountToken
				}

				if _config.priorityClassName != _|_ {
					priorityClassName: _config.priorityClassName
				}

				if _config.startupAPICheck.securityContext != _|_ {
					securityContext: _config.startupAPICheck.securityContext
				}

				containers: [{
					name:            _meta.name
					image:           _config.startupAPICheck.image.reference
					imagePullPolicy: _config.startupAPICheck.imagePullPolicy
					args: [
						"check",
						"api",
						"--wait=\(_config.startupAPICheck.timeout)",
					]
					if _config.startupAPICheck.extraArgs != _|_ {
						args: _config.startupAPICheck.extraArgs
					}

					if _config.startupAPICheck.containerSecurityContext != _|_ {
						securityContext: _config.startupAPICheck.containerSecurityContext
					}

					if _config.startupAPICheck.resources != _|_ {
						resources: _config.startupAPICheck.resources
					}

					if _config.startupAPICheck.volumeMounts != _|_ {
						volumeMounts: _config.startupAPICheck.volumeMounts
					}
				}]

				if _config.startupAPICheck.nodeSelector != _|_ {
					nodeSelector: _config.startupAPICheck.nodeSelector
				}

				if _config.startupAPICheck.affinity != _|_ {
					affinity: _config.startupAPICheck.affinity
				}

				if _config.startupAPICheck.tolerations != _|_ {
					tolerations: _config.startupAPICheck.tolerations
				}

				if _config.startupAPICheck.volumes != _|_ {
					volumes: _config.startupAPICheck.volumes
				}
			}
		}
	}
}
