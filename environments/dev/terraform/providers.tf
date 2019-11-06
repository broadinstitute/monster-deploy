###
## GCS providers are all in us-central1 (for now).
###
provider "google" {
  project = "broad-dsp-monster-dev"
  region = "us-central1"
}
provider "google-beta" {
  project = "broad-dsp-monster-dev"
  region = "us-central1"
}

###
## Set up multiple AWS providers so we can stage
## test data in many regions.
###
provider "aws" {
  region = "us-east-1"
  alias = "us-east-1"
}
provider "aws" {
  region = "us-west-2"
  alias = "us-west-2"
}

###
## Init the Vault and local providers for consistency.
###
provider "vault" {
  address = "https://clotho.broadinstitute.org:8200"
}
provider "local" {}
