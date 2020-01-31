variable account_id {
  type = string
  description = "Service account name."
}

variable display_name {
  type = string
  description = "The display name shown in the cloud console for the service account."
  default = null
}

variable vault_path {
  type = string
  description = "Vault path to the relevant GCS key."
}

variable roles {
  type = list(string)
  description = "A list of roles for the service account to have."
  default = []
}
