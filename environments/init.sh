#!/usr/bin/env bash
set -euo pipefail

declare -r SCRIPT_DIR=$(cd $(dirname ${0}) >/dev/null 2>&1 && pwd)
declare -r REPO_ROOT=$(cd $(dirname ${SCRIPT_DIR}) >/dev/null 2>&1 && pwd)

# Associative array so we can look things up by string key.
# The values don't matter as long as they're not empty.
declare -rA ENVS=([dev]=valid)
declare -r TERRAFORM_VERSION=0.12.17

function apply_terraform () {
  local -r env=$1
  local -r tf_path=${SCRIPT_DIR}/${env}/terraform
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
    -v ${tf_path}:/module
    -w /module
    hashicorp/terraform:${TERRAFORM_VERSION}
  )

  rm -rf ${tf_path}/.terraform
  ${terraform[@]} init
  ${terraform[@]} apply
}

function install_argocd () {
  1>&2 echo foo
}

main () {
  if [ $# -ne 1 ]; then
    1>&2 echo Usage: ${0} '<env>'
    exit 1
  elif [ -z ${ENVS[$1]:-""} ]; then
    1>&2 echo Error: Invalid environment "'$1'"
    exit 1
  fi

  local -r env=$1
  apply_terraform ${env}
  install_argocd ${env}
}

main ${@}
