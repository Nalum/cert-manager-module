# Cert-Manager - Timoni

[![cert-manager](https://img.shields.io/badge/cert--manager-v1.13.2-00bfff)](https://cert-manager.io)
[![timoni.sh](https://img.shields.io/badge/timoni.sh-v0.18.0-7e56c2)](https://timoni.sh)
[![kubernetes](https://img.shields.io/badge/kubernetes-v1.29.0-326CE5?logo=kubernetes&logoColor=white)](https://kubernetes.io)
[![License](https://img.shields.io/github/license/nalum/cert-manager-module)](https://github.com/nalum/cert-manager-module/blob/main/LICENSE)
[![Release](https://img.shields.io/github/v/release/nalum/cert-manager-module)](https://github.com/nalum/cert-manager-module/releases)

Example commands, where `NAME=cert-manager` and `NAMESPACE=cert-manager`. `--debug` in the `vet` command
will force timoni to use the `debug_values.cue` file in the module:

```sh
$ timoni mod vet ./modules/cert-manager --debug --namespace $NAMESPACE --name $NAME
4:32PM INF vetting with debug values
4:32PM INF Namespace/cert-manager valid resource
4:32PM INF Deployment/cert-manager/cert-manager-controller valid resource
4:32PM INF Deployment/cert-manager/cert-manager-webhook valid resource
4:32PM INF MutatingWebhookConfiguration/cert-manager/cert-manager-webhook valid resource
4:32PM INF ValidatingWebhookConfiguration/cert-manager/cert-manager-webhook valid resource
4:32PM INF Service/cert-manager/cert-manager-webhook valid resource
4:32PM INF Deployment/cert-manager/cert-manager-cainjector valid resource
4:32PM INF ConfigMap/cert-manager/cert-manager-controller valid resource
4:32PM INF NetworkPolicy/cert-manager/cert-manager-webhook-allow-egress valid resource
4:32PM INF NetworkPolicy/cert-manager/cert-manager-webhook-allow-ingress valid resource
4:32PM INF PodDisruptionBudget/cert-manager/cert-manager-controller valid resource
4:32PM INF Role/cert-manager/cert-manager-controller:leaderelection valid resource
4:32PM INF RoleBinding/cert-manager/cert-manager-controller:leaderelection valid resource
4:32PM INF ClusterRole/cert-manager-controller-view valid resource
4:32PM INF ClusterRole/cert-manager-controller-edit valid resource
4:32PM INF ClusterRole/cert-manager-controller-issuers valid resource
4:32PM INF ClusterRole/cert-manager-controller-clusterissuers valid resource
4:32PM INF ClusterRole/cert-manager-controller-certificates valid resource
4:32PM INF ClusterRole/cert-manager-controller-orders valid resource
4:32PM INF ClusterRole/cert-manager-controller-challenges valid resource
4:32PM INF ClusterRole/cert-manager-controller-ingress-shim valid resource
4:32PM INF ClusterRole/cert-manager-controller-approve:cert-manager-io valid resource
4:32PM INF ClusterRole/cert-manager-controller-certificatesigningrequests valid resource
4:32PM INF ClusterRoleBinding/cert-manager-controller-issuers valid resource
4:32PM INF ClusterRoleBinding/cert-manager-controller-clusterissuers valid resource
4:32PM INF ClusterRoleBinding/cert-manager-controller-certificates valid resource
4:32PM INF ClusterRoleBinding/cert-manager-controller-orders valid resource
4:32PM INF ClusterRoleBinding/cert-manager-controller-challenges valid resource
4:32PM INF ClusterRoleBinding/cert-manager-controller-ingress-shim valid resource
4:32PM INF ClusterRoleBinding/cert-manager-controller-approve:cert-manager-io valid resource
4:32PM INF ClusterRoleBinding/cert-manager-controller-certificatesigningrequests valid resource
4:32PM INF Role/cert-manager/cert-manager-webhook:dynamic-serving valid resource
4:32PM INF RoleBinding/cert-manager/cert-manager-webhook:dynamic-serving valid resource
4:32PM INF ClusterRole/cert-manager-webhook-subjectaccessreviews valid resource
4:32PM INF ClusterRoleBinding/cert-manager-webhook-subjectaccessreviews valid resource
4:32PM INF Service/cert-manager/cert-manager-controller valid resource
4:32PM INF ServiceMonitor/cert-manager/cert-manager-controller valid resource
4:32PM INF ServiceAccount/cert-manager/cert-manager-controller valid resource
4:32PM INF ConfigMap/cert-manager/cert-manager-webhook valid resource
4:32PM INF PodDisruptionBudget/cert-manager/cert-manager-webhook valid resource
4:32PM INF ServiceAccount/cert-manager/cert-manager-webhook valid resource
4:32PM INF PodDisruptionBudget/cert-manager/cert-manager-cainjector valid resource
4:32PM INF ClusterRole/cert-manager-cainjector valid resource
4:32PM INF ClusterRoleBinding/cert-manager-cainjector valid resource
4:32PM INF Role/cert-manager/cert-manager-cainjector:leaderelection valid resource
4:32PM INF RoleBinding/cert-manager/cert-manager-cainjector:leaderelection valid resource
4:32PM INF ServiceAccount/cert-manager/cert-manager-cainjector valid resource
4:32PM INF ClusterRole/cert-manager-controller-cluster-view valid resource
4:32PM INF CustomResourceDefinition/certificaterequests.cert-manager.io valid resource
4:32PM INF CustomResourceDefinition/certificates.cert-manager.io valid resource
4:32PM INF CustomResourceDefinition/challenges.acme.cert-manager.io valid resource
4:32PM INF CustomResourceDefinition/clusterissuers.cert-manager.io valid resource
4:32PM INF CustomResourceDefinition/issuers.cert-manager.io valid resource
4:32PM INF CustomResourceDefinition/orders.acme.cert-manager.io valid resource
4:32PM INF quay.io/jetstack/cert-manager-acmesolver:v1.13.2@sha256:7057fd605f530ab2198ebdf1cb486818cce20682632be37c90522a09b95271b1 valid image
4:32PM INF quay.io/jetstack/cert-manager-cainjector:v1.13.2@sha256:858fee0c4af069d0e87c08fd0943f0091434e05f945d222875fc1f3d36c41616 valid image
4:32PM INF quay.io/jetstack/cert-manager-controller:v1.13.2@sha256:9c67cf8c92d8693f9b726bec79c2a84d2cebeb217af6947355601dec4acfa966 valid image
4:32PM INF quay.io/jetstack/cert-manager-ctl:v1.13.2@sha256:4d9fce2c050eaadabedac997d9bd4a003341e9172c3f48fae299d94fa5f03435 valid image
4:32PM INF quay.io/jetstack/cert-manager-webhook:v1.13.2@sha256:0a9470447ebf1d3ff1c172e19268be12dc26125ff83320d456f6826c677c0ed2 valid image
4:32PM INF timoni.sh/cert-manager valid module
```

Without `--debug` it will use the `values.cue` file in the module:

```sh
$ timoni mod vet ./modules/cert-manager --namespace $NAMESPACE --name $NAME
4:31PM INF vetting with default values
4:31PM INF Namespace/cert-manager valid resource
4:31PM INF Deployment/cert-manager/cert-manager-controller valid resource
4:31PM INF Deployment/cert-manager/cert-manager-webhook valid resource
4:31PM INF MutatingWebhookConfiguration/cert-manager/cert-manager-webhook valid resource
4:31PM INF ValidatingWebhookConfiguration/cert-manager/cert-manager-webhook valid resource
4:31PM INF Service/cert-manager/cert-manager-webhook valid resource
4:31PM INF Deployment/cert-manager/cert-manager-cainjector valid resource
4:31PM INF NetworkPolicy/cert-manager/cert-manager-webhook-allow-egress valid resource
4:31PM INF NetworkPolicy/cert-manager/cert-manager-webhook-allow-ingress valid resource
4:31PM INF PodDisruptionBudget/cert-manager/cert-manager-controller valid resource
4:31PM INF Role/cert-manager/cert-manager-controller:leaderelection valid resource
4:31PM INF RoleBinding/cert-manager/cert-manager-controller:leaderelection valid resource
4:31PM INF ClusterRole/cert-manager-controller-view valid resource
4:31PM INF ClusterRole/cert-manager-controller-edit valid resource
4:31PM INF ClusterRole/cert-manager-controller-issuers valid resource
4:31PM INF ClusterRole/cert-manager-controller-clusterissuers valid resource
4:31PM INF ClusterRole/cert-manager-controller-certificates valid resource
4:31PM INF ClusterRole/cert-manager-controller-orders valid resource
4:31PM INF ClusterRole/cert-manager-controller-challenges valid resource
4:31PM INF ClusterRole/cert-manager-controller-ingress-shim valid resource
4:31PM INF ClusterRole/cert-manager-controller-approve:cert-manager-io valid resource
4:31PM INF ClusterRole/cert-manager-controller-certificatesigningrequests valid resource
4:31PM INF ClusterRoleBinding/cert-manager-controller-issuers valid resource
4:31PM INF ClusterRoleBinding/cert-manager-controller-clusterissuers valid resource
4:31PM INF ClusterRoleBinding/cert-manager-controller-certificates valid resource
4:31PM INF ClusterRoleBinding/cert-manager-controller-orders valid resource
4:31PM INF ClusterRoleBinding/cert-manager-controller-challenges valid resource
4:31PM INF ClusterRoleBinding/cert-manager-controller-ingress-shim valid resource
4:31PM INF ClusterRoleBinding/cert-manager-controller-approve:cert-manager-io valid resource
4:31PM INF ClusterRoleBinding/cert-manager-controller-certificatesigningrequests valid resource
4:31PM INF Role/cert-manager/cert-manager-webhook:dynamic-serving valid resource
4:31PM INF RoleBinding/cert-manager/cert-manager-webhook:dynamic-serving valid resource
4:31PM INF ClusterRole/cert-manager-webhook-subjectaccessreviews valid resource
4:31PM INF ClusterRoleBinding/cert-manager-webhook-subjectaccessreviews valid resource
4:31PM INF ServiceAccount/cert-manager/cert-manager-controller valid resource
4:31PM INF PodDisruptionBudget/cert-manager/cert-manager-webhook valid resource
4:31PM INF ServiceAccount/cert-manager/cert-manager-webhook valid resource
4:31PM INF PodDisruptionBudget/cert-manager/cert-manager-cainjector valid resource
4:31PM INF ClusterRole/cert-manager-cainjector valid resource
4:31PM INF ClusterRoleBinding/cert-manager-cainjector valid resource
4:31PM INF Role/cert-manager/cert-manager-cainjector:leaderelection valid resource
4:31PM INF RoleBinding/cert-manager/cert-manager-cainjector:leaderelection valid resource
4:31PM INF ServiceAccount/cert-manager/cert-manager-cainjector valid resource
4:31PM INF ClusterRole/cert-manager-controller-cluster-view valid resource
4:31PM INF CustomResourceDefinition/certificaterequests.cert-manager.io valid resource
4:31PM INF CustomResourceDefinition/certificates.cert-manager.io valid resource
4:31PM INF CustomResourceDefinition/challenges.acme.cert-manager.io valid resource
4:31PM INF CustomResourceDefinition/clusterissuers.cert-manager.io valid resource
4:31PM INF CustomResourceDefinition/issuers.cert-manager.io valid resource
4:31PM INF CustomResourceDefinition/orders.acme.cert-manager.io valid resource
4:31PM INF quay.io/jetstack/cert-manager-acmesolver:v1.13.2@sha256:7057fd605f530ab2198ebdf1cb486818cce20682632be37c90522a09b95271b1 valid image
4:31PM INF quay.io/jetstack/cert-manager-cainjector:v1.13.2@sha256:858fee0c4af069d0e87c08fd0943f0091434e05f945d222875fc1f3d36c41616 valid image
4:31PM INF quay.io/jetstack/cert-manager-controller:v1.13.2@sha256:9c67cf8c92d8693f9b726bec79c2a84d2cebeb217af6947355601dec4acfa966 valid image
4:31PM INF quay.io/jetstack/cert-manager-ctl:v1.13.2@sha256:4d9fce2c050eaadabedac997d9bd4a003341e9172c3f48fae299d94fa5f03435 valid image
4:31PM INF quay.io/jetstack/cert-manager-webhook:v1.13.2@sha256:0a9470447ebf1d3ff1c172e19268be12dc26125ff83320d456f6826c677c0ed2 valid image
4:31PM INF timoni.sh/cert-manager valid module
```

Build the module and output the yaml to `stdout`, providing a values file with `-f`:
```sh
$ timoni -n $NAMESPACE build $NAME ./modules/cert-manager -f ./modules/cert-manager/debug_values.cue
```

This uses the `values.cue` as we do not provide a values file:

```sh
$ timoni -n $NAMESPACE build $NAME ./modules/cert-manager
```
