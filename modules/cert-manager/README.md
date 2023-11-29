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

| Key                          | Type                                    | Default                    | Description                                                                                                                                  |
|------------------------------|-----------------------------------------|----------------------------|----------------------------------------------------------------------------------------------------------------------------------------------|

#### Recommended values

Comply with the restricted [Kubernetes pod security standard](https://kubernetes.io/docs/concepts/security/pod-security-standards/):

```cue
values: {}
```
