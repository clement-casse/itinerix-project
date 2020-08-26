# Project Itinerix

**Project Itinerix** is a trace processing platform based on [Jaeger Tracing](https://www.jaegertracing.io/) that comes along with a testing app generating sample traces ([microservices-demo from Google](https://github.com/GoogleCloudPlatform/microservices-demo)), [Linkerd](https://linkerd.io) has been added to the stack to provide observability to services-to services communications, thus adding more meaning to traces.
Jaeger is integrated with [Polynote](https://polynote.org/): a Spark-enabled Python and Scala Notebook that is able to request Tracing Data from Jaeger API to process it online.
It is based on the *Medium* publications of *Pavol Loffay*, a RedHat Developer working on the OpenTelemetry Working Group:

- [Data Analytics with Jaeger: a.k.a Traces tell us more](https://medium.com/jaegertracing/data-analytics-with-jaeger-aka-traces-tell-us-more-973669e6f848)
- [Jaeger Data Analytics with Jupyter Notebooks](https://medium.com/jaegertracing/jaeger-data-analytics-with-jupyter-notebooks-b094fa7ab769)
