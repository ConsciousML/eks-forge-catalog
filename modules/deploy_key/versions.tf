terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 6.55.0"
    }
    github = {
      source  = "integrations/github"
      version = "= 6.6.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "= 4.3.0"
    }
  }

  required_version = ">= 1.9.1"
}

