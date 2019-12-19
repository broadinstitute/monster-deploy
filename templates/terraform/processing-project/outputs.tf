output k8s_login {
  value = {
    endpoint = module.processing_k8s_master.endpoint,
    ca_cert = module.processing_k8s_master.ca_certificate
  }
}
