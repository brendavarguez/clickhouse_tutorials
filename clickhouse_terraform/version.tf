terraform {
  # where terraform stateful info will be stored
  backend "s3" {
    bucket = "your_bucket"
    key    = ".../.../data.tfstate" # file to be updated when a new tf deploy is made
    region = "your-aws-region"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.10.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.21.1"
    }
  }
}

# no credentials required as they are being
# read from AWS cli as env vars
provider "aws" {
  region = "your-aws-region"
}

# Data Source: aws_eks_cluster
# Retrieve information about an EKS Cluster
data "aws_eks_cluster" "infra" {
  name = "infra"
}

# Data Source: aws_eks_cluster_auth
# Get an authentication token to communicate with an EKS cluster
data "aws_eks_cluster_auth" "infra" {
  name = "infra"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.infra.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.infra.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.infra.token
}

# The Helm provider is used to deploy software packages in Kubernetes
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.infra.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.infra.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.infra.token
  }

  experiments {
    manifest = true
  }
}
