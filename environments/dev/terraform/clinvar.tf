provider google {
  project = "broad-dsp-monster-clingen-dev"
  region = "us-central1"
  alias = "clinvar"
}

provider google-beta {
  project = "broad-dsp-monster-clingen-dev"
  region = "us-central1"
  alias = "clinvar"
}

module clinvar {
  source = "/templates/processing-project"
  providers = {
    google.target = google-beta.clinvar
  }

  project_name = "broad-dsp-monster-clingen-dev"
  is_production = false
  region = "us-central1"
  k8s_zone = "a"
}
