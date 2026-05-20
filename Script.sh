AWS SSO Role Configuration
Development Account — Identity & Access Management Documentation
Environment
Development (Dev)	Last Updated
May 20, 2026	Prepared By
Infrastructure / IAM Team	Classification
Internal Use Only

1. Overview
This document describes the AWS Single Sign-On (SSO) permission sets configured for the Development (Dev) AWS account. Each role defines a specific set of service-level access permissions following the principle of least privilege, tailored to the responsibilities of the respective team function.
These roles are centrally managed through AWS IAM Identity Center and are assigned to user groups. All access is scoped to the Dev environment; production account roles are governed by a separate document.
2. Roles at a Glance
Permission Set	Primary Services	Access Level
DataAnalyst	S3, Athena, Glue, CloudWatch	Read / Limited Write
DataEngineer	S3, Glue, Athena, ECR, CloudWatch	Full Read/Write (select services)
DataScience	SageMaker, S3, Athena, Glue, ECR, CloudWatch	Full Access (select services)
Redshift_Reader	Redshift Serverless, Redshift Data API	Scoped Read-Only

3. Role Definitions
3.1.  DataAnalyst
Grants analysts the ability to query and read data assets for reporting and exploration. Write access is limited to S3 object operations; no destructive or administrative actions are permitted.
AWS Service	Access Type	Scope / Notes
Amazon S3	Read / Write Objects	Read and write S3 objects; list all buckets. Cannot delete objects or modify bucket policies.
Amazon Athena	Full Access	Query execution, workgroup management, and result retrieval.
AWS Glue	Read-Only (Catalog)	Read access to tables, databases, partitions, jobs, and crawlers. Cannot modify catalog resources.
Amazon CloudWatch	Read-Only	View logs and metrics. Cannot create or delete log groups.

3.2.  DataEngineer
Provides broader data pipeline and infrastructure access. Engineers can build, deploy, and maintain ETL pipelines, manage container images, and instrument workloads with custom metrics and logs.
AWS Service	Access Type	Scope / Notes
Amazon S3	Read / Write / Delete	Full object-level access including delete. Cannot modify bucket-level settings or policies.
AWS Glue	Full Access (*)	Complete access to all Glue resources — crawlers, jobs, triggers, workflows, and catalog metadata.
Amazon Athena	Full Access	All Athena operations including workgroup and data catalog management.
Amazon ECR	Push / Pull Images	Authenticate, push, and pull container images. Cannot create or delete repositories.
Amazon CloudWatch	Create Logs / Put Metrics	Create log streams, put log events, and publish custom metrics.
⚠  Note: Glue Full Access (*) grants broad permissions including catalog mutations. Review any Glue IAM policy changes carefully before deployment.

3.3.  DataScience
Enables data scientists to develop, train, and deploy machine learning models end-to-end. Combines SageMaker full access with supporting data and container services.
AWS Service	Access Type	Scope / Notes
Amazon SageMaker	Full Access (*)	All SageMaker operations — notebooks, training jobs, endpoints, pipelines, and model registry.
Amazon S3	Read / Write Objects	Read and write training data, model artifacts, and output files.
Amazon Athena	Full Access	Ad-hoc SQL querying against data lake for feature engineering and analysis.
AWS Glue	Full Access	Access to the data catalog and ETL jobs required for feature pipelines.
Amazon ECR	Push / Pull Images	Manage custom training and inference container images.
Amazon CloudWatch	Create / Read Logs	Create and read log streams for training job monitoring and debugging.
⚠  Note: SageMaker Full Access (*) includes permissions to create IAM roles for training jobs. Ensure SageMaker execution roles follow least-privilege separately.

3.4.  Redshift_Reader
Provides scoped, read-only access to a designated Redshift Serverless workgroup. Designed for business users and analysts who need SQL query access without administrative capabilities. Explicit deny statements prevent namespace or workgroup modifications.
AWS Service	Access Type	Scope / Notes
Redshift Serverless	GetCredentials	Credential retrieval for a specific, named workgroup only. Cross-workgroup access is not permitted.
Redshift Data API	Execute / Cancel Statements	Run and cancel SQL statements; list available databases, schemas, and tables.
Managed Policies	ReadOnlyAccess + QueryEditorV2	AmazonRedshiftReadOnlyAccess and AmazonRedshiftQueryEditorV2NoSharing attached.
Explicit Deny (IAM)	Deny — Admin Actions	Cannot create, delete, or update namespaces, workgroups, or snapshots regardless of other policies.
⚠  Note: The explicit deny on namespace/workgroup/snapshot mutations is a hard guardrail and overrides any broader policies that may be attached in future. Do not remove without a security review.

4. Access Matrix
Quick-reference matrix of service access across all roles (✓ = granted, ✗ = not granted, R = read-only).
AWS Service	DataAnalyst	DataEngineer	DataScience	Redshift_Reader
S3 Objects	✓	✓	✓	✗
S3 Delete	✗	✓	✗	✗
Athena	✓	✓	✓	✗
Glue (Full)	✗	✓	✓	✗
Glue (Read)	✓	✗	✗	✗
SageMaker	✗	✗	✓	✗
ECR	✗	✓	✓	✗
CloudWatch Logs (Write)	✗	✓	✓	✗
Redshift Data API	✗	✗	✗	✓

5. Governance & Operational Notes
Scope Limitation: All roles defined here are scoped exclusively to the Dev AWS account. Separate permission sets with additional controls govern Staging and Production environments.
Review Cadence: IAM roles and permission sets should be reviewed quarterly or whenever significant changes are made to the data platform architecture.
Full Access (*) Disclaimer: Roles granted Full Access (*) to a service (Glue, SageMaker) inherit all current and future actions for that service. Monitor AWS release notes for new permissions that may expand scope unintentionally.
Explicit Deny Precedence: The Explicit Deny on Redshift_Reader overrides any Allow policies, including administrator policies. This is by design and must not be removed without a security review and change-control approval.
Audit & Monitoring: CloudTrail is enabled on the Dev account. All API calls, including those made via SSO sessions, are logged. CloudWatch dashboards should be configured to alert on anomalous activity.
Least Privilege Principle: Roles are designed around the principle of least privilege. If a team member requires access beyond what their assigned role provides, submit a temporary access request through the IAM request process.
