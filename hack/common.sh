#####
## Common definitions used across scripts.
#####

#####
## Constants.
#####
declare -r KUBECTL=lachlanevenson/k8s-kubectl:v1.14.10
declare -r HELM=lachlanevenson/k8s-helm:v3.0.2
declare -r HELM_OPERATOR_VERSION=v1.0.0-rc8
declare -r SECRETS_MANAGER_VERSION=release-1.0.2

#####
## Get names for the processing projects registered in the environment.
##
## Functions like this are why the directory is named 'hack'. Assumes that
## all processing-project clusters in the environment have information stored
## in Vault under a common prefix, and that the names of the directories found
## immediately under that prefix are meant to represent project names.
#####
function get_processing_names () {
  local -r env=$1
  local -r vault_prefix=secret/dsde/monster/${env}/processing-projects/

  declare -ra project_names=($(vault list ${vault_prefix} | grep '/' | sed 's#/##g'))
  echo ${project_names[@]}
}

#####
## Read the kubeconfig for a command-center GKE cluster from its expected
## Vault path for the target environment.
#####
function get_command_center_config () {
  local -r env=$1 config_target=$2

  vault read -field=kubeconfig secret/dsde/monster/${env}/command-center/gke > ${config_target}
}

#####
## Read the kubeconfig for a processing GKE cluster from its expected
## Vault path for the target environment.
#####
function get_processing_config () {
  local -r env=$1 project=$2 config_target=$3

  vault read -field=kubeconfig secret/dsde/monster/${env}/processing-projects/${project}/gke > ${config_target}
}
