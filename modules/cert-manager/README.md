# cert-manager

A [timoni.sh](http://timoni.sh) module for deploying cert-manager to Kubernetes clusters.

## Install

To create an instance using the default values:

```shell
timoni -n cert-manager apply cert-manager oci://ghcr.io/nalum/timoni/cert-manager
```

To change the [default configuration](#configuration),
create one or more `values.cue` files and apply them to the instance.

For example, create a file `my-values.cue` with the following content:

```cue
values: {
    controller: {
        prometheus: enabled: true
    }

    test: enabled: true
}
```

And apply the values with:

```shell
timoni -n cert-manager apply cert-manager oci://<ghcr.io/nalum/timoni/cert-manager \
--values ./my-values.cue
```

## Uninstall

To uninstall an instance and delete all its Kubernetes resources:

```shell
timoni -n cert-manager delete cert-manager
```

## Configuration

### General values

| Key                          | Required        | Type                                    | Default                    | Description                                                                                                                                  |
|------------------------------|-----------------|-----------------------------------------|----------------------------|----------------------------------------------------------------------------------------------------------------------------------------------|
| `acmeSolver: image:` | `true` | `timoniv1.#Image` | `_\|_` | Holds the configuration for pulling the ACME Solver container |
| `acmeSolver: imagePullPolicy:` | `false` | `string` | `PullIfNotPresent` | Instruction on how to treat pulling the container |
| `caInjector:` | `false` | `struct` | `_\|_` | The configuration of the cert-manager cainjector |
| `caInjector: config:` | `false` | `{[string]: string}` | `_\|_` | |
| `caInjecotr: args:` | `false` | `[string]` | `_\|_` | |
| `controller:` | `true` | `string` | `_\|_` | |
| `controller: clusterResourceNamespace:` | `false | `string` | `_\|_` | |
| `controller: config:` | `false` | `struct` | `_\|_` | |
| `controller: dns01RecursiveNameservers:` | `false` | `string` | `_\|_` | |
| `controller: dns01RecursiveNameserversOnly:` | `false` | `bool` | `false` | |
| `controller: enableCertificateOwnerRef:` | `false` | `bool` | `false` | |
| `controller: featureGates:` | `false` | `string` | `_\|_` | |
| `controller: ingressShim:` | `false` | `struct` | `_\|_` | |
| `controller: ingressShim: defaultIssuerGroup:` | `false` | `string` | `_\|_` | |
| `controller: ingressShim: defaultIssuerKind:` | `false` | `string` | `ClusterIssuer` | |
| `controller: ingressShim: defaultIssuerName:` | `false` | `string` | `_\|_` | |
| `controller: maxConcurrentChallenges:` | `false` | `int` | `60` | |
| `controller: podDNSConfig:` | `false` | `corev1.#PodDNSConfig` | `_\|_` | |
| `controller: podDNSPolicy:` | `false` | `string` | `ClusterFirst` | |
| `controller: prometheus:` | `false | `struct` | `_\|_` | |
| `controller: prometheus: serviceMonitor: annotations?:` | `false` | `timoniv1.#Annotations` | `_\|_` | |
| `controller: prometheus: serviceMonitor: endpointAdditionalProperties:` | `false` | `{[ string]: string}` | `_\|_` | |
| `controller: prometheus: serviceMonitor: honorLabels:` | `false` | `bool` | `false` | |
| `controller: prometheus: serviceMonitor: interval:` | `false` | `string` | `60s` | |
| `controller: prometheus: serviceMonitor: labels:` | `false` | `timoniv1.#Labels` | `_\|_` | |
| `controller: prometheus: serviceMonitor: path:` | `false` | `string` | `/metrics` | |
| `controller: prometheus: serviceMonitor: prometheusInstance:` | `false` | `string` | `default` | |
| `controller: prometheus: serviceMonitor: scrapeTimeout:` | `false` | `string` | `30s` | |
| `controller: prometheus: serviceMonitor: targetPort:` | `false` | `string`/`int` | `http-metrics` | |
| `controller: prometheus: serviceMonitor:` | `false` | `struct` | `_\|_` | |
| `imagePullSecrets:` | `false` | `[corev1.#LocalObjectReference]` | `_\|_` | List of image pull secrets to supply to the resources being deployed |
| `leaderElection:` | `false` | `struct` | `struct` | Holds the required configuration for the leader election |
| `leaderElection: leaseDuration:` | `false` | `#Duration` | `60s` | The duration the lease is held |
| `leaderElection: namespace:` | `false` | `string` | `kube-system` | The namespace used to hold the leader election lease |
| `leaderElection: renewDeadline:` | `false` | `#Duration` | `40s` | The deadline duration for renewal |
| `leaderElection: retryPeriod:` | `false` | `#Duration` | `15s` | The duration for the retry period |
| `logLevel:` | `false` | `int` | `2` | Logging verbosity |
| `podSecurityAdmission:` | `false` | `struct` | | Pod Security Admission |
| `podSecurityAdmission: mode:` | `false` | `string` | `enforce` | |
| `podSecurityAdmission: level:` | `false` | `string` | `restricted` | |
| `priorityClassName:` | `false` | `string` | `_\|_` | The name of the kubernetes priority class to apply to resources |
| `rbac: aggregateClusterRoles:` | `false` | `bool` | `true` | Aggregate ClusterRoles to Kubernetes default user-facing roles. Ref: https://kubernetes.io/docs/reference/access-authn-authz/rbac/#user-facing-roles |
| `rbac:` | `false` | `struct` | `_\|_` | Setup the Cluster RBAC roles and bindings |
| `webhook:` | `true` | `#Webhook` | `#Webhook` | The configuration of the cert-manager webhook |
| `webhook: args:` | `false` | `[string]` | `_\|_` | |
| `webhook: config:` | `false` | `struct` | `_\|_` | |
| `webhook: config: apiVersion:` | `false` | `string` | `webhook.config.cert-manager.io/v1alpha1` | |
| `webhook: config: kind:` | `false` | `string` | `WebhookConfiguration` | |
| `webhook: config: securePort:` | `false` | `int` | `10250` | |
| `webhook: featureGates:` | `false` | `string` | `_\|_` | |
| `webhook: hostNetwork:` | `false` | `bool` | `_\|_` | |
| `webhook: loadBalancerIP:` | `false` | `string` | `_\|_` | |
| `webhook: mutatingWebhookConfigurationAnnotations:` | `false` | `timoniv1.#Annotations` | `_\|_` | |
| `webhook: networkPolicy:` | `false` | `networkingv1.#NetworkPolicySpec` | `_\|_` | |
| `webhook: securePort:` | `false` | `int` | `10250` | |
| `webhook: timeoutSeconds:` | `false` | `int` | `10` | |
| `webhook: url: host?:` | `false` | `string` | `_\|_` | |
| `webhook: validatingWebhookConfigurationAnnotations:` | `false` | `timoniv1.#Annotations` | `_\|_` | |

#### Recommended values

Comply with the restricted [Kubernetes pod security standard](https://kubernetes.io/docs/concepts/security/pod-security-standards/):

```cue
values: {}
```
