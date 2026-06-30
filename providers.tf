terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }
  }
}


# -----------------------------------------------------------------------------
# AWS Provider
# -----------------------------------------------------------------------------

# Configure the root provider
provider "aws" {
  region  = var.region
  profile = var.profile != "" ? var.profile : null
}

# Verify provider connectivity and collect caller information
data "aws_caller_identity" "current" {}


# -----------------------------------------------------------------------------
# Kubernetes Provider
# -----------------------------------------------------------------------------

# Configure the root provider
provider "kubernetes" {
  host                   = concat(module.eks_cluster[*].cluster_endpoint, [""])[0]
  cluster_ca_certificate = base64decode(concat(module.eks_cluster[*].cluster_ca_cert, [""])[0])
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", local.eks_cluster_name]
    command     = "aws"
  }
}

# Provider for EKS Local Cluster (requires --cluster-id with UUID)
provider "kubernetes" {
  alias                  = "local_cluster"
  host                   = concat(module.eks_on_outposts[*].cluster_endpoint, [""])[0]
  cluster_ca_certificate = base64decode(concat(module.eks_on_outposts[*].cluster_ca_cert, [""])[0])
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-id", concat(module.eks_on_outposts[*].cluster_id, [""])[0]]
    command     = "aws"
  }
}
