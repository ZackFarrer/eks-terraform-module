provider "aws" {
  region = data.aws_region.current.name
}

provider "helm" {
  kubernetes {
  host                   = data.aws_eks_cluster.eks_cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    command     = "aws"
  }
}

registry {
  url      = "oci://${data.aws_caller_identity.current.account_id}.dkr.ecr.eu-west-2.amazonaws.com"
  username = data.aws_ecr_authorization_token.token.user_name
  password = data.aws_ecr_authorization_token.token.password
}
}

provider "kubectl" {
  host                   = data.aws_eks_cluster.eks_cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    command     = "aws"
  }
}