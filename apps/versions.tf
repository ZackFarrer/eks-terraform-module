terraform {
  required_version = ">= 0.14.8"
  required_providers {
    aws = {
        source  = "hashicorp/aws"
        version = "5.66.0"
    }
    helm = {
        source  = "hashicorp/helm"
        version = "2.15.0"
    }
    kubectl = {
        source  = "alekc/kubectl"
        version = "2.0.4"
    }
  }
}