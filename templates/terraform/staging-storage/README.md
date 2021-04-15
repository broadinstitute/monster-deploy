# Staging Storage
This module creates a staging GCS bucket with permissions appropriate for our ETL infrastructure. The intent of
staging buckets is to enable external consortia to deposit data for ingest in our infrastructure.

This module provisions the bucket itself as well as the following permissions and entities:
1. Access for our orchestration frameworks (dagster + argo)
2. An SA external groups can leverage to deposit data in the bucket via the Storage Transfer Service
3. TDR SA acct access for file ingest

An optional "external admin group" may be provided as well, and will be granted admin access if present. 