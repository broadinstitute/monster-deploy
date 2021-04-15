# Staging Storage
This module creates a staging GCS bucket with permissions appropriate for our ETL infrastructure.
This includes:
1. Access for our orchestration frameworks (dagster + argo)
2. An SA external groups can leverage to deposit data in the bucket via the Storage Transfer Service
3. TDR SA acct access for file ingest

An optional "external admin group" may be provided as well, and will be granted admin access if present. 