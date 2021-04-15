module dap {
  source = "../../../templates/terraform/dap"
  project_name = "broad-dsp-monster-dap-${var.env}"
  vault_prefix = "secret/dsde/monster/{${var.env}/dog-aging/redcap-tokens/automation"
}