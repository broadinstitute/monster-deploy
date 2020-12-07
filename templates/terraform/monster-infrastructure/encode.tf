module encode {
  source = ".//processing-project"
  providers = {
    google.target = google.encode,
    vault.target = vault.target
  }

  project_name = "broad-dsp-monster-encode-${local.env}"
  is_production = var.is_production
  command_center_argo_account_email = module.command_center.encode_argo_runner_email
  region = "us-west1"
  jade_repo_email = local.jade_repo_email
  deletion_age_days = 14
  vault_prefix = "${local.vault_prefix}/processing-projects/encode"
}

module encode_s3_user {
  source = ".//aws-sa"
  providers = {
    aws.target = aws.encode
  }

  account_id = "monster-${local.env}-encode-downloader"
  vault_path = "${local.vault_prefix}/processing-projects/encode/s3-downloader"

  iam_policy = [
    {
      subject_id = "ObjectActions",
      actions = ["s3:GetObject"]
      resources = [
        "arn:aws:s3:::encode-public/*"
      ]
    }
  ]
}
