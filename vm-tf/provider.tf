terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.14.0"
    }
  }
}

provider "google" {
  project     = "constant-goods-415103"
  region      = "us-central1"
  zone        = "us-central1-a"
  credentials = "./keys.json"
}
