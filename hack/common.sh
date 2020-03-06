#####
## Common definitions used across scripts.
#####

#####
## Constants.
#####
declare -r TERRAFORM=hashicorp/terraform:0.12.20
declare -r KUBECTL=lachlanevenson/k8s-kubectl:v1.14.10
declare -r HELM=lachlanevenson/k8s-helm:v3.0.3

declare -r HELM_OPERATOR_VERSION=v1.0.0-rc8
declare -r SECRETS_MANAGER_VERSION=release-1.0.2
declare -r ARGO_VERSION=v2.6.1
declare -r PROMETHEUS_OPERATOR_VERSION=release-0.36

#####
## Read the kubeconfig for a command-center GKE cluster from its expected
## Vault path for the target environment.
#####
function get_command_center_config () {
  local -r env=$1 config_target=$2

  vault read -field=kubeconfig secret/dsde/monster/${env}/command-center/gke > ${config_target}
}
