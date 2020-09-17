# Project Itinerix

**Project Itinerix** is a trace processing platform based on [Jaeger Tracing](https://www.jaegertracing.io/) that comes along with a testing app generating sample traces ([microservices-demo from Google](https://github.com/GoogleCloudPlatform/microservices-demo)), [Linkerd](https://linkerd.io) has been added to the stack to provide observability to services-to services communications, thus adding more insight to traces.
Jaeger is integrated with [Polynote](https://polynote.org/): a Spark-enabled Python and Scala Notebook that is able to request Tracing Data from Jaeger API to process it online.
This project has been created as a PoC for my PhD where I use graph processing applied to tracing data.

This work has been inspired by the *Medium* publications of *Pavol Loffay*, a RedHat Developer working on the OpenTelemetry Working Group:

- [Data Analytics with Jaeger: a.k.a Traces tell us more](https://medium.com/jaegertracing/data-analytics-with-jaeger-aka-traces-tell-us-more-973669e6f848)
- [Jaeger Data Analytics with Jupyter Notebooks](https://medium.com/jaegertracing/jaeger-data-analytics-with-jupyter-notebooks-b094fa7ab769)

This project contains manifests that deploy on GKE an environment containing:

- A sample Cloud application that comes along with a load generator
- This application is monitored by State-of-the-Art tools (Jaeger, Prometheus, OpenTelemetry Agent and Collectors)
- These Tools (currently only Jaeger) are linked to a Data processing platform (Polynote) that also has Graph backend running both Gremlin and Cypher.

Along with Polynote come example Notebooks that illustrate interconnection with other services within the application, they are stored in the directory [`./kustomizations/data/polynote/overlays/gke/polynote/notebooks`](https://github.com/clement-casse/itinerix-project/tree/master/kustomizations/data/polynote/overlays/gke/polynote/notebooks)

- **[JaegerTracesIngest](https://kokes.github.io/nbviewer.js/viewer.html#aHR0cHM6Ly9naXRodWIuY29tL2NsZW1lbnQtY2Fzc2UvaXRpbmVyaXgtcHJvamVjdC9ibG9iL21hc3Rlci9rdXN0b21pemF0aW9ucy9ncmFwaGVyL3BvbHlub3RlL292ZXJsYXlzL2drZS9wb2x5bm90ZS9ub3RlYm9va3MvSmFlZ2VyVHJhY2VzSW5nZXN0LmlweW5i)** where we connect to a Jaeger Instance and parse data to the model defined in the Notebook
- **[GremlinServerConnection](https://kokes.github.io/nbviewer.js/viewer.html#aHR0cHM6Ly9naXRodWIuY29tL2NsZW1lbnQtY2Fzc2UvaXRpbmVyaXgtcHJvamVjdC9ibG9iL21hc3Rlci9rdXN0b21pemF0aW9ucy9ncmFwaGVyL3BvbHlub3RlL292ZXJsYXlzL2drZS9wb2x5bm90ZS9ub3RlYm9va3MvR3JlbWxpblNlcnZlckNvbm5lY3Rpb24uaXB5bmI=)** where we connect to a remote gremlin server instance installed within our stack
- **[GremlinServerBoltConnection](https://kokes.github.io/nbviewer.js/viewer.html#aHR0cHM6Ly9naXRodWIuY29tL2NsZW1lbnQtY2Fzc2UvaXRpbmVyaXgtcHJvamVjdC9ibG9iL21hc3Rlci9rdXN0b21pemF0aW9ucy9ncmFwaGVyL3BvbHlub3RlL292ZXJsYXlzL2drZS9wb2x5bm90ZS9ub3RlYm9va3MvR3JlbWxpblNlcnZlckJvbHRDb25uZWN0aW9uLmlweW5i)** where we connect to the remote GremlinServer using the bolt protocol and querying it via Cypher

## Motivation

**The idea behind this project is take profit of the heavily connected nature of trace data to create and maintain at runtime a property graph modeling the performance of the monitored Cloud-Application.**

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
