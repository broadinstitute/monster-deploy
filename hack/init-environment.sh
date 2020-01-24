#!/usr/bin/env bash
set -euo pipefail

declare -r SCRIPT_DIR=$(cd $(dirname ${0}) >/dev/null 2>&1 && pwd)
declare -r REPO_ROOT=$(cd $(dirname ${SCRIPT_DIR}) >/dev/null 2>&1 && pwd)

# Associative array so we can look things up by string key.
# The values don't matter as long as they're not empty.
declare -rA ENVS=([dev]=valid)

declare -ra COMMAND_CENTER_NAMESPACES=(
  fluxcd
  airflow
  argo-ui
  clinvar
  encode
  dog-aging
  secret-manager
)
declare -ra PROCESSING_NAMESPACES=(
  argo
  secret-manager
)

declare -r TERRAFORM=hashicorp/terraform:0.12.17
declare -r KUBECTL=lachlanevenson/k8s-kubectl:v1.14.10
declare -r HELM=lachlanevenson/k8s-helm:v3.0.2

declare -r HELM_OPERATOR_VERSION=v1.0.0-rc5
declare -r HELM_OPERATOR_CHART_VERSION=0.4.0

declare -r KUBECONFIG_DIR_NAME=.kubeconfig


#####
## Run Terraform to initialize "always on" infrastructure
## for a given environment.
#####
function apply_terraform () {
  local -r env_dir=$1
  local -r tf_template_path=${REPO_ROOT}/templates/terraform

  declare -ra terraform=(
    docker run
    --rm -it
    # Local ssh configs for GitHub
    -v ${HOME}/.ssh:/root/.ssh
    # Local gcloud configs
    -v ${HOME}/.config:/root/.config
    # Local AWS configs
    -e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
    -e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
    -e AWS_REGION=${AWS_REGION}
    # Local vault configs
    -e VAULT_ADDR=${VAULT_ADDR}
    -v ${HOME}/.vault-token:/root/.vault-token
    # Terraform template paths
    -v ${tf_template_path}:/templates
    # Terraform source paths
    -v ${env_dir}:/env
    -w /env/terraform
    ${TERRAFORM}
  )

  rm -rf ${env_dir}/terraform/.terraform
  ${terraform[@]} init
  ${terraform[@]} apply -var="kubeconfig_dir_path=/env/${KUBECONFIG_DIR_NAME}"
}


#####
## Initialize namespaces in a GKE cluster so we can
## deploy into it.
##
## Helm used to create namespaces automatically but
## dropped the behavior in v3 to be consistent with
## kubectl. It's probably better to be explicit anyway.
#####
function create_namespaces () {
  local -r kubeconfig=$1
  shift
  local -ra namespaces=${@}

  declare -ra kubectl=(
    docker run
    # NOTE: `-t` omitted here on purpose because it's incompatible
    # with `-a stdin`.
    --rm -i
    # Read from stdin so we can pipe in YAML.
    -a stdin -a stdout -a stderr
    # Configure the client to point at the cluster.
    -v ${kubeconfig}:/root/.kube/config:ro
    # Make sure it can auth with GKE.
    -v ${HOME}/.config:/root/.config
    ${KUBECTL}
  )

  for ns in ${namespaces[@]}; do
    # kubectl apply a HEREDOC containing YAML for each namespace.
    #
    # It'd be simpler if we could just `kubectl create namespace ${ns}`.
    # We can't do that because `create` fails when there's already a
    # namespace with the given name. `apply` is idempotent, but it
    # only accepts YAML / JSON as input -_-
    ${kubectl[@]} apply -f - <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: ${ns}
EOF
  done
}


#####
## Set up Flux CD's Helm Operator to manage deployments in GKE.
#####
function install_flux () {
  local -r kubeconfig=$1 env_dir=$2

  # Install the CRD definitions separately. Helm doesn't have
  # a coherent story for handling these yet (since updating them
  # the wrong way can result in all existing objects being deleted),
  # so they're easier to handle out-of-band.
  docker run --rm -it \
    -v ${kubeconfig}:/root/.kube/config:ro \
    -v ${HOME}/.config:/root/.config:ro \
    ${KUBECTL} \
    apply -f \
    https://raw.githubusercontent.com/fluxcd/helm-operator/${HELM_OPERATOR_VERSION}/deploy/flux-helm-release-crd.yaml

  # Install the Operator using Helm.
  declare -ra helm=(
    docker run
    --rm -it
    # Configure the client to point at the cluster.
    -v ${kubeconfig}:/root/.kube/config:ro
    # Make sure it can auth with GKE.
    -v ${HOME}/.config:/root/.config:ro
    # Persist Helm config across container runs.
    -v ${env_dir}/.helm/plugins:/root/.local/share/helm/plugins
    -v ${env_dir}/.helm/config:/root/.config/helm
    -v ${env_dir}/.helm/cache:/root/.cache/helm
    ${HELM}
  )

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
## Install Flux HelmRelease CRDs for all the software we want to
## have running in the command-center GKE cluster.
##
## The Helm Operator will monitor the git repo specified in each
## CRD and re-deploy whenever the target ref changes.
#####
function install_charts () {
  1>&2 echo TODO
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
  local -r env_dir=${REPO_ROOT}/environments/$1
  if [ -z ${SKIP_TF:-""} ]; then
    apply_terraform ${env_dir}
  fi

  # Set up GKE namespaces.
  local -r kubeconfig_dir=${env_dir}/${KUBECONFIG_DIR_NAME}
  local -r command_center_config=${kubeconfig_dir}/command-center
  local -r processing_configs_dir=${kubeconfig_dir}/processing

  create_namespaces ${command_center_config} ${COMMAND_CENTER_NAMESPACES[@]}
  for kubeconfig in ${processing_configs_dir}/*; do
    create_namespaces ${kubeconfig} ${PROCESSING_NAMESPACES[@]}
  done

  # Install command-center services.
  install_flux ${command_center_config} ${env_dir}
  install_charts
}

main ${@}
