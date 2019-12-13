variable dependencies {
  type = any
  default = []
  description = "Work-around for Terraform 0.12's lack of support for 'depends_on' in custom modules."
}

variable name {
  type = string
  description = "Name to assign to the network and its subnets"
}

variable subnets {
  type = list(object({
    region = string,
    cidr = string
  }))
}

variable enable_flow_logs {
  type = bool
}
