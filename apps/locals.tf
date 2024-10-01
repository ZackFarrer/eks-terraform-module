locals {
  oidc_id          = replace(data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer, "https://", "")
  ami_id           = length(var.ami_id) == 0 ? data.aws_ami.ami_name[0].id : var.ami_id
  account_id       = data.aws_caller_identity.current.account_id
  eks_cidr         = data.aws_vpc.eks_vpc.cidr_block
  ami_family_lower = lower(var.ami_family)

  combined_default_and_data_tags = merge(
    data.aws_default_tags.default_resource_tags.tags,
    var.tags,
  )

  karpenter_helm_values = templatefile("${path.module}/templates/karpenter-helm-values.yaml", {
    cluster_name     = data.aws_eks_cluster.eks_cluster.id,
    queue_name       = module.karpenter.queue_name
    role_arn         = module.karpenter.iam_role_arn
    cluster_endpoint = data.aws_eks_cluster.eks_cluster.endpoint
    account_id       = local.account_id
    region           = data.aws_region.current.name
    image_tag        = "1.0.3"
    image_digest     = "abc123"
  })
}
