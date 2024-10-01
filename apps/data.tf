data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "ecr_authorization_token" "token" {}

data "aws_eks_cluster" "eks_cluster" {
  name = var.cluster_name  
}

data "aws_eks_cluster_auth" "eks_cluster" {
  name = var.cluster_name  
}

data "aws_iam_session_context" "current" {
  arn = data.aws_caller_identity.current.arn
}

data "aws_vpc" "eks_vpc" {
  id = data.aws_eks_cluster.eks_cluster.vpc_config[0].vpc_id
}

data "aws_security_group" "eks_nodegroup_sg" {
  filter {
    name   = "tag:Name"
    values = ["${var.cluster_name}-nodegroup-sg*"]
  }
}

data "aws_iam_role" "eks_nodegroup_role" {
    name = "${var.cluster_name}-ng-role"
}