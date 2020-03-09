#####
## Common definitions used across scripts.
#####

#####
## Constants.
#####
declare -r TERRAFORM=hashicorp/terraform:0.12.20
declare -r KUBECTL=lachlanevenson/k8s-kubectl:v1.14.10
declare -r HELM=lachlanevenson/k8s-helm:v3.0.3

declare -r HELM_CHARTS_DIR=${REPO_ROOT}/templates/helm

#####
## Read the kubeconfig for a command-center GKE cluster from its expected
## Vault path for the target environment.
#####
function get_command_center_config () {
  local -r env=$1 config_target=$2

  vault read -field=kubeconfig secret/dsde/monster/${env}/command-center/gke > ${config_target}
}

#####
## Configure Helm in Docker
#####
function configure_helm () {
  local -r kubeconfig=$1 helm_dir=$2

  declare -ra helm=(
    docker run
    --rm -it
    # Configure the client to point at the cluster.
    -v ${kubeconfig}:/root/.kube/config:ro
    # Make sure it can auth with GKE.
    -v ${HOME}/.config/gcloud:/root/.config/gcloud:ro
    # Persist Helm config across container runs.
    -v ${helm_dir}/plugins:/root/.local/share/helm/plugins
    -v ${helm_dir}/config:/root/.config/helm
    -v ${helm_dir}/cache:/root/.cache/helm
    # Make our local charts available.
    -v ${HELM_CHARTS_DIR}:/charts
    ${HELM}
  )
  echo ${helm[@]}
}

#####
## Ensure namespaces exist in a GKE cluster so we can
## deploy into them.
##
## Helm used to create namespaces automatically but
## dropped the behavior in v3 to be consistent with
## kubectl. It's probably better to be explicit anyway.
#####
function apply_namespaces () {
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
    -v ${HOME}/.config/gcloud:/root/.config/gcloud:ro
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
## Apply arbitrary resource URLs into a GKE cluster.
##
## This is primarily useful for CRD API definitions. Helm used to
## allow deploying CRD APIs like any other resource, but it changed
## the behavior in v3 to 1) remove templating of CRDs and 2) only
## install CRDs, and never update them. Explicit control of the APIs
## is probably better anyways, since updating them in the wrong way
## can cause all existing objects of the kind to be wiped out.
#####
function apply_urls () {
  local -r kubeconfig=$1
  shift
  local -ra urls=${@}

  declare -ra kubectl=(
    docker run
    --rm -it
    # Configure the client to point at the cluster.
    -v ${kubeconfig}:/root/.kube/config:ro
    # Make sure it can auth with GKE.
    -v ${HOME}/.config/gcloud:/root/.config/gcloud:ro
    ${KUBECTL}
  )

  for url in ${urls[@]}; do
    ${kubectl[@]} apply -f ${url}
  done
}
