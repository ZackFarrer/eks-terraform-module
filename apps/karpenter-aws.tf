# AWS Karpenter module which creates the prerequisite AWS resources for karpenter to successfully run
# See https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest/submodules/karpenter
module "karpenter" {
  source = "terraform-aws-modules/eks/aws//modules/karpenter"

  cluster_name = var.cluster_name
  
  # Use the same role that the AWS EKS Nodegroup is using
  create_node_iam_role = false
  node_iam_role_arn    = data.aws_iam_role.eks_nodegroup_role.arn

  # Since the node group role will already have an access entry
  create_access_entry = false

  tags = var.tags
}