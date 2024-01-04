# cert-manager

A [timoni.sh](http://timoni.sh) module for deploying cert-manager to Kubernetes clusters.

## Install

To create an instance using the default values:

```shell
timoni -n default apply cert-manager oci://<container-registry-url>
```

To change the [default configuration](#configuration),
create one or more `values.cue` files and apply them to the instance.

For example, create a file `my-values.cue` with the following content:

```cue
values: {}
```

And apply the values with:

```shell
timoni -n default apply cert-manager oci://<container-registry-url> \
--values ./my-values.cue
```

## Uninstall

To uninstall an instance and delete all its Kubernetes resources:

```shell
timoni -n default delete cert-manager
```

## Configuration

### General values

| Key                          | Required        | Type                                    | Default                    | Description                                                                                                                                  |
|------------------------------|-----------------|-----------------------------------------|----------------------------|----------------------------------------------------------------------------------------------------------------------------------------------|
| `imagePullSecrets?` | `false` | `[...corev1.LocalObjectReference]` | `_|_` | List of image pull secrets to supply to the resources being deployed |
| `priorityClassName` | `false` | `string` | `_|_` | The name of the kubernetes priority class to apply to resources |
| `rbac` | `false` | `struct` | `_|_` | Setup the Cluster RBAC roles and bindings |
| `rbac.aggregateClusterRoles` | `false` | `bool` | `true` | Aggregate ClusterRoles to Kubernetes default user-facing roles. Ref: https://kubernetes.io/docs/reference/access-authn-authz/rbac/#user-facing-roles |
| `podSecurityPolicy` | `false` | `struct` | `_|_` | Pod Security Policy |
| `podSecurityPolicy.useAppArmor | `false` | `bool` | `true` | |
| `logLevel` | `false` | `int` | `2` | Logging verbosity |
| `leaderElection` | `false` | `struct` | `struct` | Holds the required configuration for the leader election |
| `leaderElection.namespace` | `false` | `string` | `kube-system` | The namespace used to hold the leader election lease |
| `leaderElection.leaseDuration` | `false` | `#Duration` | `60s` | The duration the lease is held |
| `leaderElection.renewDeadline` | `false` | `#Duration` | `40s` | The deadline duration for renewal |
| `leaderElection.retryPeriod` | `false` | `#Duration` | `15s` | The duration for the retry period |
| `controller` | `true` | `#Controller` | `#Controller` | The configuration of the cert-manager controller |
| `webhook` | `true` | `#Webhook` | `#Webhook` | The configuration of the cert-manager webhook |
| `caInjector` | `true` | `#CAInjector` | `#CAInjector` | The configuration of the cert-manager cainjector |
| `acmeSolver` | `false` | `struct` | `struct` | The configuration for the ACME Solver container |
| `acmeSolver.image` | `true` | `timoniv1.#Image` | `_|_` | Holds the configuration for pulling the ACME Solver container |
| `acmeSolver.imagePullPolicy` | `false` | `#ImagePullPolicy` | `PullIfNotPresent` | Instruction on how to treat pulling the container |
| `startupAPICheck` | `false` | `#StartupAPICheck` | `#StartupAPICheck` | The configuration of the cert-manager startup api check job |

#### Recommended values

Comply with the restricted [Kubernetes pod security standard](https://kubernetes.io/docs/concepts/security/pod-security-standards/):

```cue
values: {}
```
