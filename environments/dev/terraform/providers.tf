provider "google" {
  project = "broad-dsp-monster-dev"
  region = "us-central1"
}

provider "google-beta" {
  project = "broad-dsp-monster-dev"
  region = "us-central1"
}

provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  region = "us-west-2"
  alias = "west-2"
}

provider "vault" {
  address = "https://clotho.broadinstitute.org:8200"
}
