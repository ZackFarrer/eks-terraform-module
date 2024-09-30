data "aws_caller_identity" "current" {}

data "aws_region "current" {}

data "aws_ecr_authorization_token" "token" {}

data "aws_default_tags" "default_resource_tags" {
  provider = aws
}

data "aws_eks_cluster" "eks_cluster" {
  name = aws_eks_cluster.eks_cluster.id
}

data "aws_eks_cluster_auth" "eks_cluster" {
  name = aws_eks_cluster.eks_cluster.id
}

data "tls_certificate" "eks_ca" {
  url = aws_eks_cluster.eks_cluster.indentity[0].oidc[0].issuer
}

data "aws_iam_session_context" "current" {
  arn = data.aws_caller_identity.current.arn
}

data "aws_vpc" "eks_vpc" {
  id = aws_eks_cluster.eks_cluster.vpc_config[0].vpc_id
}
