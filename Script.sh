For the new setup, where are we expected to run Kafka Connect/Debezium — as Kafka Connect pods in EKS managed through Kustomize/ArgoCD, or is MSK Connect still being considered?
Is Strimzi officially part of this implementation, or should we proceed with standard Kubernetes/Kustomize resources
Is the target flow still expected to be: RDS PostgreSQL → Debezium → Kafka/MSK topics → EKS services?
