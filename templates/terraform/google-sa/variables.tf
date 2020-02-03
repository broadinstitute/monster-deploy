variable account_id {
  type = string
  description = "Name to assign to the new account."
}

variable display_name {
  type = string
  description = "Display name to assign to the new account."
  default = null
}

variable vault_path {
  type = string
  description = "Vault path where the new account's GCS key should be stored."
}

variable roles {
  type = list(string)
  description = "A list of roles for the service account to have."
  default = []
}

variable dependencies {
  type = any
  default = []
  description = "Work-around for Terraform 0.12's lack of support for 'depends_on' in custom modules."
}
