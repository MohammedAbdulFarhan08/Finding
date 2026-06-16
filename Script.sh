I'm a senior DevOps engineer migrating this Kafka Connect / Debezium setup from the current environment to a new AWS account. The new environment uses EKS, ArgoCD, MSK (Kafka 3.9.x, TLS on port 9094), Aurora PostgreSQL, and AWS Secrets Manager with Secrets Store CSI Driver. I need to extract specific configuration details to recreate this setup. Please analyze the entire repository and answer the following:

1. DEPLOYMENT MODEL
   - How is Kafka Connect deployed? (Strimzi KafkaConnect CRD, Helm chart, plain Kubernetes manifests, Docker Compose, other?)
   - What Kubernetes resources are defined? (Deployments, StatefulSets, Services, ConfigMaps, Secrets, CRDs?)
   - Is Strimzi used? If yes, which Strimzi components (Topic Operator, KafkaConnect, KafkaConnector, User Operator)?

2. DEBEZIUM CONNECTOR CONFIGURATIONS
   - List every Debezium connector configured (name, connector class)
   - For each connector, provide:
     - database.hostname / database.port / database.dbname
     - topic.prefix
     - schema.include.list or table.include.list
     - slot.name (replication slot)
     - publication.name
     - plugin.name (pgoutput, decoderbufs, wal2json?)
     - snapshot.mode (initial, schema_only, never, etc.)
     - Any custom transforms or SMTs (Single Message Transforms)
   - Are connectors defined as Strimzi KafkaConnector CRDs, REST API calls, ConfigMaps, or JSON files?

3. SERIALIZATION & SCHEMA REGISTRY
   - What is the key.converter and value.converter? (JSON, Avro, Protobuf?)
   - Is a Schema Registry used? If yes, what is the URL and configuration?
   - Are schemas.enable set to true or false?

4. KAFKA CONNECT WORKER CONFIGURATION
   - What is the bootstrap.servers value?
   - What is the group.id?
   - What security.protocol is used? (PLAINTEXT, SSL, SASL_SSL, SASL_PLAINTEXT?)
   - What are the internal topic names? (offset.storage.topic, config.storage.topic, status.storage.topic)
   - What are the replication factors for internal topics?
   - Any custom worker-level properties?

5. CONTAINER IMAGES
   - What container image is used for Kafka Connect?
   - What version of Debezium is installed?
   - Are there any additional connector plugins or JARs bundled?
   - Is there a Dockerfile or build process for a custom image?

6. CREDENTIALS & SECRETS
   - How are database credentials provided? (env vars, mounted files, Kubernetes secrets, Vault, other?)
   - How are Kafka/MSK credentials provided?
   - List all environment variables or secret references used by the Kafka Connect pods
   - Are there any TLS/SSL keystores or truststores configured?

7. TOPIC CONFIGURATION
   - Are topics pre-created or auto-created by Debezium?
   - If pre-created, list all topic names with their partition count and replication factor
   - Are there any topic-level configs? (retention.ms, cleanup.policy, etc.)
   - If Strimzi Topic Operator is used, list all KafkaTopic CRDs

8. NETWORKING & CONNECTIVITY
   - What ports are exposed?
   - Any Ingress or Service configurations for the Kafka Connect REST API?
   - Any network policies?

9. RESOURCE ALLOCATIONS
   - CPU and memory requests/limits for Kafka Connect pods
   - Replica count
   - Any JVM heap settings (KAFKA_HEAP_OPTS)?

10. MONITORING & HEALTH
    - Any JMX configuration?
    - Health check / liveness / readiness probes defined?
    - Any Prometheus metrics exporters?

For each answer, include the exact file path and relevant code snippet so I can trace it back. If something is not present in the repo, explicitly say "not found in repo."
