package templates

import (
	rbacv1 "k8s.io/api/rbac/v1"
	timoniv1 "timoni.sh/core/v1alpha1"

	cfg "timoni.sh/cert-manager/templates/config"
)

#ClusterRole: rbacv1.#ClusterRole & {
	#config:    cfg.#Config
	#component: string
	#role?:     string
	#aggregate: *false | bool
	#aggregateTo: {
		reader: *false | bool
		view:   *false | bool
		edit:   *false | bool
		admin:  *false | bool
	}

	#meta: timoniv1.#MetaComponent & {
		#Meta:      #config.metadata
		#Component: #component
	}

	apiVersion: "rbac.authorization.k8s.io/v1"
	kind:       "ClusterRole"

	if #role != _|_ {
		metadata: name: "\(#meta.name)-\(#role)"
	}

	if #role == _|_ {
		metadata: name: "\(#meta.name)"
	}

	metadata: labels: #meta.labels

	if #aggregate == true {
		if #aggregateTo.reader == true {
			metadata: labels: "rbac.authorization.k8s.io/aggregate-to-cluster-reader": "true"
		}

		if #aggregateTo.view == true {
			metadata: labels: "rbac.authorization.k8s.io/aggregate-to-view": "true"
		}

		if #aggregateTo.edit == true {
			metadata: labels: "rbac.authorization.k8s.io/aggregate-to-edit": "true"
		}

		if #aggregateTo.admin == true {
			metadata: labels: "rbac.authorization.k8s.io/aggregate-to-admin": "true"
		}
	}

	if #meta.annotations != _|_ {
		metadata: annotations: #meta.annotations
	}

	if #component == "controller" {
		// Cluster View
		if #role == "cluster-view" {
			rules: [{
				apiGroups: ["cert-manager.io"]
				resources: ["clusterissuers"]
				verbs: ["get", "list", "watch"]
			}]
		}

		// View
		if #role == "view" {
			rules: [{
				apiGroups: ["cert-manager.io"]
				resources: ["certificates", "certificaterequests", "issuers"]
				verbs: ["get", "list", "watch"]
			}, {
				apiGroups: ["acme.cert-manager.io"]
				resources: ["challenges", "orders"]
				verbs: ["get", "list", "watch"]
			}]
		}

		// Edit
		if #role == "edit" {
			rules: [{
				apiGroups: ["cert-manager.io"]
				resources: ["certificates", "certificaterequests", "issuers"]
				verbs: ["create", "delete", "deletecollection", "patch", "update"]
			}, {
				apiGroups: ["cert-manager.io"]
				resources: ["certificates/status"]
				verbs: ["update"]
			}, {
				apiGroups: ["acme.cert-manager.io"]
				resources: ["challenges", "orders"]
				verbs: ["create", "delete", "deletecollection", "patch", "update"]
			}]
		}

		// Controller Issuers
		if #role == "issuers" {
			rules: [{
				apiGroups: ["cert-manager.io"]
				resources: ["issuers", "issuers/status"]
				verbs: ["update", "patch"]
			}, {
				apiGroups: ["cert-manager.io"]
				resources: ["issuers"]
				verbs: ["get", "list", "watch"]
			}, {
				apiGroups: [""]
				resources: ["secrets"]
				verbs: ["get", "list", "watch", "create", "update", "delete"]
			}, {
				apiGroups: [""]
				resources: ["events"]
				verbs: ["create", "patch"]
			}]
		}

		// Controller ClusterIssuers
		if #role == "clusterissuers" {
			rules: [{
				apiGroups: ["cert-manager.io"]
				resources: ["clusterissuers", "clusterissuers/status"]
				verbs: ["update", "patch"]
			}, {
				apiGroups: ["cert-manager.io"]
				resources: ["clusterissuers"]
				verbs: ["get", "list", "watch"]
			}, {
				apiGroups: [""]
				resources: ["secrets"]
				verbs: ["get", "list", "watch", "create", "update", "delete"]
			}, {
				apiGroups: [""]
				resources: ["events"]
				verbs: ["create", "patch"]
			}]
		}

		// Controller Certificates
		if #role == "certificates" {
			rules: [{
				apiGroups: ["cert-manager.io"]
				resources: ["certificates", "certificates/status", "certificaterequests", "certificaterequests/status"]
				verbs: ["update", "patch"]
			}, {
				apiGroups: ["cert-manager.io"]
				resources: ["certificates", "certificaterequests", "clusterissuers", "issuers"]
				verbs: ["get", "list", "watch"]
			}, {
				// We require these rules to support users with the OwnerReferencesPermissionEnforcement
				// admission controller enabled:
				// https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#ownerreferencespermissionenforcement
				apiGroups: ["cert-manager.io"]
				resources: ["certificates/finalizers", "certificaterequests/finalizers"]
				verbs: ["update"]
			}, {
				apiGroups: ["acme.cert-manager.io"]
				resources: ["orders"]
				verbs: ["create", "delete", "get", "list", "watch"]
			}, {
				apiGroups: [""]
				resources: ["secrets"]
				verbs: ["get", "list", "watch", "create", "update", "delete", "patch"]
			}, {
				apiGroups: [""]
				resources: ["events"]
				verbs: ["create", "patch"]
			}]
		}

		// Controller Orders
		if #role == "orders" {
			rules: [{
				apiGroups: ["acme.cert-manager.io"]
				resources: ["orders", "orders/status"]
				verbs: ["update", "patch"]
			}, {
				apiGroups: ["acme.cert-manager.io"]
				resources: ["orders", "challenges"]
				verbs: ["get", "list", "watch"]
			}, {
				apiGroups: ["cert-manager.io"]
				resources: ["clusterissuers", "issuers"]
				verbs: ["get", "list", "watch"]
			}, {
				apiGroups: ["acme.cert-manager.io"]
				resources: ["challenges"]
				verbs: ["create", "delete"]
			}, {
				// We require these rules to support users with the OwnerReferencesPermissionEnforcement
				// admission controller enabled:
				// https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#ownerreferencespermissionenforcement
				apiGroups: ["acme.cert-manager.io"]
				resources: ["orders/finalizers"]
				verbs: ["update"]
			}, {
				apiGroups: [""]
				resources: ["secrets"]
				verbs: ["get", "list", "watch"]
			}, {
				apiGroups: [""]
				resources: ["events"]
				verbs: ["create", "patch"]
			}]
		}

		// Controller Challenges
		if #role == "challenges" {
			rules: [{
				// Use to update challenge resource status
				apiGroups: ["acme.cert-manager.io"]
				resources: ["challenges", "challenges/status"]
				verbs: ["update", "patch"]
			}, {
				// Used to watch challenge resources
				apiGroups: ["acme.cert-manager.io"]
				resources: ["challenges"]
				verbs: ["get", "list", "watch"]
			}, {
				// Used to watch challenges, issuer and clusterissuer resources
				apiGroups: ["cert-manager.io"]
				resources: ["issuers", "clusterissuers"]
				verbs: ["get", "list", "watch"]
			}, {
				// Need to be able to retrieve ACME account private key to complete challenges
				apiGroups: [""]
				resources: ["secrets"]
				verbs: ["get", "list", "watch"]
			}, {
				// Used to create events
				apiGroups: [""]
				resources: ["events"]
				verbs: ["create", "patch"]
			}, {
				// HTTP01 rules
				apiGroups: [""]
				resources: ["pods", "services"]
				verbs: ["get", "list", "watch", "create", "delete"]
			}, {
				apiGroups: ["networking.k8s.io"]
				resources: ["ingresses"]
				verbs: ["get", "list", "watch", "create", "delete", "update"]
			}, {
				apiGroups: ["gateway.networking.k8s.io"]
				resources: ["httproutes"]
				verbs: ["get", "list", "watch", "create", "delete", "update"]
			}, {
				// We require the ability to specify a custom hostname when we are creating
				// new ingress resources.
				// See: https://github.com/openshift/origin/blob/21f191775636f9acadb44fa42beeb4f75b255532/pkg/route/apiserver/admission/ingress_admission.go#L84-L148
				apiGroups: ["route.openshift.io"]
				resources: ["routes/custom-host"]
				verbs: ["create"]
			}, {
				// We require these rules to support users with the OwnerReferencesPermissionEnforcement
				// admission controller enabled:
				// https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#ownerreferencespermissionenforcement
				apiGroups: ["acme.cert-manager.io"]
				resources: ["challenges/finalizers"]
				verbs: ["update"]
			}, {
				// DNS01 rules (duplicated above)
				apiGroups: [""]
				resources: ["secrets"]
				verbs: ["get", "list", "watch"]
			}]
		}

		// Controller Ingress Shim
		if #role == "ingress-shim" {
			rules: [{
				apiGroups: ["cert-manager.io"]
				resources: ["certificates", "certificaterequests"]
				verbs: ["create", "update", "delete"]
			}, {
				apiGroups: ["cert-manager.io"]
				resources: ["certificates", "certificaterequests", "issuers", "clusterissuers"]
				verbs: ["get", "list", "watch"]
			}, {
				apiGroups: ["networking.k8s.io"]
				resources: ["ingresses"]
				verbs: ["get", "list", "watch"]
			}, {
				// We require these rules to support users with the OwnerReferencesPermissionEnforcement
				// admission controller enabled:
				// https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#ownerreferencespermissionenforcement
				apiGroups: ["networking.k8s.io"]
				resources: ["ingresses/finalizers"]
				verbs: ["update"]
			}, {
				apiGroups: ["gateway.networking.k8s.io"]
				resources: ["gateways", "httproutes"]
				verbs: ["get", "list", "watch"]
			}, {
				apiGroups: ["gateway.networking.k8s.io"]
				resources: ["gateways/finalizers", "httproutes/finalizers"]
				verbs: ["update"]
			}, {
				apiGroups: [""]
				resources: ["events"]
				verbs: ["create", "patch"]
			}]
		}

		// Approve cert-manager-io
		if #role == "approve:cert-manager-io" {
			rules: [{
				apiGroups: ["cert-manager.io"]
				resources: ["signers"]
				verbs: ["approve"]
				resourceNames: ["issuers.cert-manager.io/*", "clusterissuers.cert-manager.io/*"]
			}]
		}

		// Certificate Signing Requests
		if #role == "certificatesigningrequests" {
			rules: [{
				apiGroups: ["certificates.k8s.io"]
				resources: ["certificatesigningrequests"]
				verbs: ["get", "list", "watch", "update"]
			}, {
				apiGroups: ["certificates.k8s.io"]
				resources: ["certificatesigningrequests/status"]
				verbs: ["update", "patch"]
			}, {
				apiGroups: ["certificates.k8s.io"]
				resources: ["signers"]
				resourceNames: ["issuers.cert-manager.io/*", "clusterissuers.cert-manager.io/*"]
				verbs: ["sign"]
			}, {
				apiGroups: ["authorization.k8s.io"]
				resources: ["subjectaccessreviews"]
				verbs: ["create"]
			}]
		}
	}

	if #component == "webhook" {
		if #role == "subjectaccessreviews" {
			rules: [{
				apiGroups: ["authorization.k8s.io"]
				resources: ["subjectaccessreviews"]
				verbs: ["create"]
			}]
		}
	}

	if #component == "cainjector" {
		rules: [{
			apiGroups: ["cert-manager.io"]
			resources: ["certificates"]
			verbs: ["get", "list", "watch"]
		}, {
			apiGroups: [""]
			resources: ["secrets"]
			verbs: ["get", "list", "watch"]
		}, {
			apiGroups: [""]
			resources: ["events"]
			verbs: ["get", "create", "update", "patch"]
		}, {
			apiGroups: ["admissionregistration.k8s.io"]
			resources: ["validatingwebhookconfigurations", "mutatingwebhookconfigurations"]
			verbs: ["get", "list", "watch", "update", "patch"]
		}, {
			apiGroups: ["apiregistration.k8s.io"]
			resources: ["apiservices"]
			verbs: ["get", "list", "watch", "update", "patch"]
		}, {
			apiGroups: ["apiextensions.k8s.io"]
			resources: ["customresourcedefinitions"]
			verbs: ["get", "list", "watch", "update", "patch"]
		}]
	}
}
