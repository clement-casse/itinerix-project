FROM tinkerpop/gremlin-server:3.4.7

ARG NEO4J_GREMLIN_VERSION=3.4.7
ARG NEO4J_TINKERPOP_API_IMPL_VERSION=0.7-3.2.3

RUN set -eux; \
# neo4j-tinkerpop-api-impl version is 2 parts, "${its version}:${neo4j version}"
    export NEO4J_VERSION="${NEO4J_TINKERPOP_API_IMPL_VERSION#*-}"; \
    ./bin/gremlin-server.sh install org.apache.tinkerpop neo4j-gremlin "${NEO4J_GREMLIN_VERSION}"; \
    ./bin/gremlin-server.sh install org.neo4j neo4j-tinkerpop-api-impl "${NEO4J_TINKERPOP_API_IMPL_VERSION}"; \
    ./bin/gremlin-server.sh install org.neo4j neo4j-bolt "${NEO4J_VERSION}";

COPY ./conf /opt/gremlin-server/conf

EXPOSE 8182 7867

VOLUME [ "/opt/gremlin-server/data/neo4j" ]

## Inherited from Gremlin server
# WORKDIR /opt/gremlin-server/
# USER gremlin  # UID 100 - GID 101

CMD [ "conf/gremlin-server.yaml" ]