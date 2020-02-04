#!/usr/bin/env bash
set -euo pipefail

declare -r SCRIPT_DIR=$(cd $(dirname ${0}) >/dev/null 2>&1 && pwd)
declare -r REPO_ROOT=$(cd $(dirname ${SCRIPT_DIR}) >/dev/null 2>&1 && pwd)

# Associative array so we can look things up by string key.
# The values don't matter as long as they're not empty.
declare -rA ENVS=([dev]=valid)

declare -r HELM=lachlanevenson/k8s-helm:v3.0.2

declare -r HELM_OPERATOR_CHART_VERSION=0.4.0
declare -r SECRETS_MANAGER_CHART_VERSION=0.0.4

declare -r KUBECONFIG_DIR_NAME=.kubeconfig

#####
## Configure Helm in Docker
#####
function configure_helm () {
  local -r kubeconfig=$1 env_dir=$2

  declare -ra helm=(
    docker run
    --rm -it
    # Configure the client to point at the cluster.
    -v ${kubeconfig}:/root/.kube/config:ro
    # Make sure it can auth with GKE.
    -v ${HOME}/.config/gcloud:/root/.config/gcloud:ro
    # Persist Helm config across container runs.
    -v ${env_dir}/.helm/plugins:/root/.local/share/helm/plugins
    -v ${env_dir}/.helm/config:/root/.config/helm
    -v ${env_dir}/.helm/cache:/root/.cache/helm
    ${HELM}
  )
  echo ${helm[@]}
}

#####
## Set up Flux CD's Helm Operator to manage deployments in GKE.
#####
function install_flux () {
  local -r kubeconfig=$1 env_dir=$2

  # Install the Operator using Helm.
  declare -ra helm=($(configure_helm ${kubeconfig} ${env_dir}))

  rm -rf ${env_dir}/.helm
  ${helm[@]} repo add fluxcd https://charts.fluxcd.io
  ${helm[@]} upgrade helm-operator fluxcd/helm-operator \
    --install \
    --wait \
    --namespace=fluxcd \
    --version=${HELM_OPERATOR_CHART_VERSION} \
    --set='helm.versions=v3' \
    --set='rbac.pspEnabled=true'
}

#####
## Set up and install the Vault secret manager in the command center GKE cluster.
#####
function install_secrets_manager () {
  local -r kubeconfig=$1 env_dir=$2 env=$3

  # vault location
  local -r vault_location=secret/dsde/monster/${env}/approle-monster-${env}

  # Install the Operator using Helm.
  declare -ra helm=($(configure_helm ${kubeconfig} ${env_dir}))
  rm -rf ${env_dir}/.helm
  # helm repo adds Jade’s Helm repository
  ${helm[@]} repo add datarepo-helm https://broadinstitute.github.io/datarepo-helm
  # helm repo upgrade --installs the secret manager chart, setting appropriate values
  ${helm[@]} upgrade install-secrets-manager datarepo-helm/install-secrets-manager \
    --install \
    --wait \
    --namespace=secrets-manager \
    --version=${SECRETS_MANAGER_CHART_VERSION} \
    --set='installcrd.install=false' \
    --set='vaultLocation=https://clotho.broadinstitute.org:8200' \
    --set='vaultVersion=kv2' \
    --set='serviceAccount.create=true' \
    --set='rbac.create=true' \
    --set="secretsgeneric.roleId=$(vault read -field=role_id $vault_location)" \
    --set="secretsgeneric.secretId=$(vault read -field=secret_id $vault_location)"
}

#####
## Set up Google's CloudSQL Proxy to communicate with the CloudSQL database.
#####
function install_cloudsql_proxy () {
  local -r kubeconfig=$1 env_dir=$2 env=$3

  # Configure helm
  local -ra helm=($(configure_helm ${kubeconfig} ${env_dir}))

  # Read cloudsql configuration info from vault
  local -r vault_location=secret/dsde/monster/${env}/command-center/cloudsql/instance
  local -r name=$(vault read -field=name $vault_location)
  local -r region=$(vault read -field=region $vault_location)
  local -r project=$(vault read -field=project $vault_location)

  local -r vault_sa_location=secret/dsde/monster/${env}/command-center/gcs/sa-key

  # Add helm repo
  ${helm[@]} repo add datarepo-helm https://broadinstitute.github.io/datarepo-helm

  # Write CloudSQL connection secrets to GKE
  ${helm[@]} upgrade --install sqlproxy-secret datarepo-helm/create-secret-manager-secret --namespace cloudsql-proxy \
    --version=0.0.5 \
    --set secrets[0].secretName=cloudsqlkey \
    --set secrets[0].vals[0].kubeSecretKey=cloudsqlkey.json \
    --set secrets[0].vals[0].path=$vault_sa_location \
    --set secrets[0].vals[0].vaultKey=key

  # Install and upgrade CloudSQL Proxy
  ${helm[@]} upgrade --install pg-sqlproxy datarepo-helm/gcloud-sqlproxy --namespace cloudsql-proxy \
    --version=0.19.4 \
    --set cloudsql.instances[0].instance=$name \
    --set cloudsql.instances[0].project=$project \
    --set cloudsql.instances[0].region=$region \
    --set cloudsql.instances[0].port=5432 -i \
    --set rbac.create=true \
    --set existingSecret=cloudsqlkey \
    --set existingSecretKey=cloudsqlkey.json
}

#####
## Script entrypoint.
#####
function main () {
  if [ $# -ne 1 ]; then
    1>&2 echo Usage: ${0} '<env>'
    exit 1
  elif [ -z ${ENVS[$1]:-""} ]; then
    1>&2 echo Error: Invalid environment "'$1'"
    exit 1
  fi

  # Start by running Terraform. This will set up infrastructure and
  # generate configs needed for creating Helm releases.
  #
  # NOTE: Set the SKIP_TF env variable to any value to skip over this
  # step when testing changes to the k8s portiion.
  local -r env=$1
  local -r env_dir=${REPO_ROOT}/environments/${env}

  # Initialize GKE Configurations.
  local -r kubeconfig_dir=${env_dir}/${KUBECONFIG_DIR_NAME}
  local -r command_center_config=${kubeconfig_dir}/command-center
  local -r processing_configs_dir=${kubeconfig_dir}/processing

  # Initialize command-center GKE and services.
  install_flux ${command_center_config} ${env_dir}
  install_secrets_manager ${command_center_config} ${env_dir} ${env}
  install_cloudsql_proxy ${command_center_config} ${env_dir} ${env}

  # Initialize processing GKEs and services.
  for kubeconfig in ${processing_configs_dir}/*; do
    install_secrets_manager ${kubeconfig} ${env_dir} ${env}
  done
}

main ${@}
