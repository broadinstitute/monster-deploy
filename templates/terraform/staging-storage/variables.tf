
variable "area_name" {
  type = string
  description = "Name of the staging area"
}

variable "project_name" {
  type = string
  description = "Name of the GCP project that will own this bucket"
}

variable "external_writer_sa_account_name" {
  type = string
  description = "Name of the external SA that will deposit files into the bucket"
}

variable "dev_vault_prefix" {
  type = string
  description = "Path in vault to store the external SA credentials upon generation"
}

variable "tdr_repo_email" {
  type = string
  description = "Email of the TDR acct that should have access to this bucket for file ingest"
}

variable "hca_dataflow_email" {
  type = string
  description = "Email of the dataflow acct that should have access to this bucket"
}

variable "external_admin_group" {
  type = string
  default = null
  description = "(Optional) Google group that will receive access to this bucket"
}