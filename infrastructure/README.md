# Itinerix-Infrastructure Terraform project

In this directory we describe a Terraform project which aims to deploy/destroy/tune a PoC infrastructure in the most automated and reproducible way.

## Directory Structure

In this `infrastructure` directory, subdirectories follow the convention described in [This article on Terraform practices for project structure](https://medium.com/@dav009/terraform-sane-practices-project-structure-c4347c1bc0f1).
Although, the version of Terraform used in this project is at least 0.13, which involves some shifts in the conventions described in the article but does not have major notables differences.

Instead of using the three directories named `stg`, `dev` and `prod`, the only directory created has been given the name `main` and covers the scope of the PoC that fits the needs of my PhD experiments.
As described in the article the main role of this directory is to call modules and to combine their outputs to create a multiple stages deployment plan that creates a cluster and provision them with preconfigurated monitoring services.
This `main` directory can be copied and modified to use the same modules but to inject other configurations and make an alternative deployments.

The module directory is build following the same ideas as decribed in the article: it covers independant modules that are composed together in the `main` directory.

## Modules index

### `cluster-google-cloud`

[`modules/cluster-google-cloud`](./modules/cluster-google-cloud) creates a two-zones Kubernetes Cluster on Google Cloud Engine with 2 zonal peristent disks hosted in Zone 2 (These disks are used to save Polynote and neo4j state).

### `dns-google-cloud`

[`modules/dns-google-cloud`](./modules/dns-google-cloud) declares a managed zone in Google Cloud Engine withn3 sub domains :

- `app.${domain}` will be used as Host header to route to the toy application hosted in the cluster (but not deployed by terraform)
- `monitoring.${domain}` will be used as Host header to route to monitoring tools (Jaeger, Prometheus)
- `grapher.${domain}` will be used as Host header to route to the notebook engine

> You must buy the domain and configure the name provider to use custom nameservers and enter Google Cloud Nameservers (usually like `ns-cloud-a1.googledomains.com` or `ns-cloud-b1.googledomains.com`), this terraform does not subscribe the domain name to any name providers, although it might handle TLS Certificate generation.

### `operator-prometheus`

[`modules/operator-prometheus`](./modules/operator-prometheus) installs Prometheus Operator onto the target cluster, it allows to easily manges prometheus instances within the cluster by creating new kind of resources in the cluster.

> Before running Terraform, Kubernetes manifests should be generated, to do so :
>
> ```sh
> cd ./modules/operator-prometheus
> make all
> ```
>
> Due to a limitation of terraform kubectl provider (the state can become too big to be encoded via gRPC and exceeds the 4MB limit iirc) CRDs are downloaded by the make command but not managed by terraform.
> The issue is known and ideas to patch this are welcome

### `operator-strimzi`

[`modules/operator-strimzi`](./modules/operator-strimzi)

> Using make is required to generate manifests
>
> Module not used to avoid state inflation

### `prepare-stack-app`

[`modules/prepare-stack-app`](./modules/prepare-stack-app)

@TODO

### `service-mesh-istio`

[`modules/service-mesh-istio`](./modules/service-mesh-istio)

@TODO

### `service-mesh-linkerd`

[`modules/service-mesh-linkerd`](./modules/service-mesh-linkerd)

@TODO

### `stack-data`

[`modules/stack-data`](./modules/stack-data)

@TODO

### `stack-tracing`

[`modules/stack-tracing`](./modules/stack-tracing)

@TODO
