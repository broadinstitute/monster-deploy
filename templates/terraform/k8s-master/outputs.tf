output name {
  value = google_container_cluster.master.name
}

output kubeconfig {
  value = <<EOF
apiVersion: v1
kind: Config
current-context: context
contexts: [{name: context, context: {cluster: ${google_container_cluster.master.name}, user: local-user}}]
users: [{name: local-user, user: {auth-provider: {name: gcp}}}]
clusters:
- name: ${google_container_cluster.master.name}
  cluster:
    server: "https://${google_container_cluster.master.endpoint}"
    certificate-authority-data: "${google_container_cluster.master.master_auth[0].cluster_ca_certificate}"
EOF
}
