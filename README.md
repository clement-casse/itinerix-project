# Project Itinerix

**Project Itinerix** has been created as a PoC for my PhD where I use graph processing applied to tracing data.

This is an integration project that takes State-of-the-Art Cloud Monitoring tools in aim to create an end-to-end trace processing platform within a Kubernetes Cluster.
The scope of this repository covers:

1. Creation of The Kubernetes Cluster
1. Installation & Configuration of a Service Mesh in aim to gain Observability at the network level within the Cloud Application.
1. Installation & Configuration of Cloud Native Monitoring Tools (Jaeger and Prometheus) following OpenTelemetry recommendation as much as possible.
1. Installation & Configuration of a Notebook engine feed with Monitoring Tools as Data-Source.
1. Installation & Configuration of a Neo4j Graph Database to store and process graph created within the Notebook
1. Installation & ~~hacking~~ tunning a sample Cloud Application compatible with tracing.

> This work has been inspired by the *Medium* publications of *Pavol Loffay*, a RedHat Developer working on the OpenTelemetry Working Group:
>
> - [Data Analytics with Jaeger: a.k.a Traces tell us more](https://medium.com/jaegertracing/data-analytics-with-jaeger-aka-traces-tell-us-more-973669e6f848)
> - [Jaeger Data Analytics with Jupyter Notebooks](https://medium.com/jaegertracing/jaeger-data-analytics-with-jupyter-notebooks-b094fa7ab769)

## Context & Motivation

**The key idea behind this project is take profit of the heavily connected nature of tracing data to create and maintain, at runtime, a property graph modeling the performance of a Cloud-Application.**

Nowadays more and more applications are developed to be Cloud-Native, which means some constraints:

- The application is developed as a fully distributed system
- Components are disposable and may be volatile
- The application is built on top of abstractions layers managed by third-parties that may not be monitored

Monitoring such systems involves addressing new challenges in the APM community.
Indeed, for Cloud-Applications, **ensuring bottlenecks are identified** is a critical criteria for delivering the service and scaling.
Also, the **ability to identify the root-cause** in an error propagation scenario is also crucial to patch and recover the system.
*These challenges involve maintaining a global view of a rapidly evolving distributed system*.

This is why tracing became an important topic among the companies doing their business in the Clouds [[1], [2], [3], [4], [5]].
Recent initiatives like [OpenTelemetry](https://opentelemetry.io) aims to normalize, and also to provide an implementation, on how trace data is passed from the monitoring system to the APM.
As a result, we can expect tracing data to follow some well-defined schema [[6]] and to respect some semantic conventions [[7], [8]].

However, state-of-the-art trace-based APM lack maturity and fail to provide a global view of the system.
Their main purpose is helping the developer to understand interactions between the components while debugging and optimizing their code [[9]].

[1]: https://eng.uber.com/distributed-tracing/ "Uber evolution of tracing"
[2]: https://blog.twitter.com/engineering/en_us/a/2012/distributed-systems-tracing-with-zipkin.html "Twitter opensourced Zipkin"
[3]: https://ai.google/research/pubs/pub36356 "Google publication on Dapper"
[4]: https://www.usenix.org/system/files/osdi18-veeraraghavan.pdf "Facebook publication Maelstrom"
[5]: https://eng.lyft.com/envoy-joins-the-cncf-dc18baefbc22 "Lyft with Envoy-Proxy"
[6]: https://github.com/open-telemetry/opentelemetry-specification/blob/master/specification/api-tracing.md "OpenTelemetry Tracing API"
[7]: https://github.com/open-telemetry/opentelemetry-specification/blob/master/specification/data-resource-semantic-conventions.md "Resource Semantic Conventions"
[8]: https://github.com/open-telemetry/opentelemetry-specification/blob/master/specification/data-semantic-conventions.md#span-conventions "Span Semantic Conventions"
[9]: https://medium.com/@copyconstruct/distributed-tracing-weve-been-doing-it-wrong-39fc92a857df "Distributed Tracing — we’ve been doing it wrong Cindy Sridharan"

## Architecture

### Telemetry Data Flow

![creating traces with a service mesh and OpenTelemetry](https://docs.google.com/drawings/d/e/2PACX-1vRvp2JOD00-Mi1j8xdJPXQtCL4wJXJrGvCRFKXhOxgJXS2LvVyYnokhY1MPwiV-YKjLmYFO_1lZ3PxG/pub?w=1060&amp;h=722)

This illustration does not mention the technology used for the service Mesh, indeed as of today the twon main Service Mesh are evaluated:

1. Linkerd: *Implemented* Linkerd proxies send OpenCensus formated data to local OpenTelemetry agent that then forwards to a OpenTelemetry Collector
2. Istio: *Still Implementing* in aim to get number of bytes exchanged in each network communications.

## Deploying Itinerix Platform

### Before launching the platform

This projects relies on some *Infrastructure as Code* (IaC) tools in order to get the deployment as automated as possible, please install these tools by following the documentation of each links:

1. [Terraform >= v0.13](https://learn.hashicorp.com/tutorials/terraform/install-cli): Terraform is the IaC tool compatible with the widest spectrum of Cloud providers. It is used to automate the various stages of the deployment and to have a reproducible way to create the platform.
1. [kubectl >= v1.19](https://kubernetes.io/fr/docs/tasks/tools/install-kubectl/): kubectl is the command line interface used to apply Kubernetes manifests to a Kuberntes cluster but also to debug applications deployed on the cluster.
1. [Kustomize >= v3.8](https://kubernetes-sigs.github.io/kustomize/installation/): Kustomize is a tool that is used to merge multiple Kubernetes manifests files. It is heavyly used in this repository to keep configuration logically organized. Eventhough Kustomise is now bundled into `kubectl`, different behaviours have been observed between the standalone version and the bundled version when using advanced strategig merges, the standalone version has been kept because of the quicker pace of update the tool receive.
1. [gcloud](https://cloud.google.com/sdk/docs/install): if deploying the Kubernetes Cluster on Google Cloud (which is the only target cluster currently supported btw), both Terraform and `kubectl` will require the `gcloud` cli.
1. [GNU Make](https://www.gnu.org/software/make/): proabaly already installed on your machine, Make is used to bootstrap some kustomize commands or to retreive publically available Kubernetes Manifests, it does not bring any value out of this small scope, but avoids copy-pasting public code in the repository.

In order to deploy the Kubernetes cluster on Google Cloud, a Google Account is required, you might want more information [Google Cloud Free Tier](https://cloud.google.com/free).
Follow [this basic tutorial](https://cloud.google.com/kubernetes-engine/docs/quickstart#defaults) to ensure `gcloud` is correcly authenticated (pick **Local shell**).

### Running deployment

> This section is Work in Progress

Itinerix deployment is a 2-stages process, each having its own directory within the project:

1. **Deploying common components** with a [Terraform](https://www.terraform.io) project hosted within the [`./infrastructure`](https://github.com/clement-casse/itinerix-project/tree/master/infrastructure) directory: This deploys on GCP a Zonal Kuberntestes cluster with the Linkerd Service Mesh, a Jaeger All-in-One instance and various other modules that configure the plateform.

1. **Deploying Test Application**: @TODO
