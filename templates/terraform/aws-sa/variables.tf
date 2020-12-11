variable account_id {
  type        = string
  description = "Name to assign to the new account."
}

variable vault_path {
  type        = string
  description = "Vault path where the new account's GCS key should be stored."
}

variable iam_policy {
  type        = list(object({ subject_id = string, actions = list(string), resources = list(string) }))
  description = "AWS policies to apply to the new account."
}
