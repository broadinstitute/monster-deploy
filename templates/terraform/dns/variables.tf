variable dns_names {
  type = list(string)
  description = "List of DNS names to generate global IP addresses, A-records, and CNAME-records for."
}

variable dependencies {
  type = any
  default = []
  description = "Work-around for Terraform 0.12's lack of support for 'depends_on' in custom modules."
}

variable zone_name {
  type = string
  description = "DNS zone name for any new DNS resources."
}
