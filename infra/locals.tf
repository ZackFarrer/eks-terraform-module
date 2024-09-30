locals {
  oidc_id    = replace(data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer, "https://", "")
  ami_id     = length(var.ami_id) == 0 ? data.aws_ami.ami_name[0].id : var.ami_id
  account_id = data.aws_caller_identity.current.account_id

  default_clientid_list = [
    "sts.amazonaws.com",
    "sts.${data.aws_region.current.name}.amazonaws.com"
  ]

  default_thumbprint_list = [
    data.tls_certificate.eks_ca.certificates[0].sha1_fingerprint,
  ]

  eks_cidr = data.aws_vpc.eks_vpc.cidr_block

  al2_userdata_path = "${path.module}/templates/userdata-al2.sh"
  al2_userdata      = templatefile(local.al2_userdata_path, {
    cluster_id                        = aws_eks_cluster.eks_cluster.id
    apiserver_endpoint                = aws_eks_cluster.eks_cluster.endpoint
    cluster_certificate_authority_b64 = aws_eks_cluster.eks_cluster.certificate_authority[0].data
    bootstrap_extra_args              = var.eks_bootstrap_extra_args
    kubelet_extra_args                = var.kubelet_extra_args
  })

  al2023_userdata_path = "${path.module}/templates/userdata-al2023.sh"
  al2023_userdata      = templatefile(local.al2023_userdata_path, {
    cluster_id                        = aws_eks_cluster.eks_cluster.id
    apiserver_endpoint                = aws_eks_cluster.eks_cluster.endpoint
    cluster_certificate_authority_b64 = aws_eks_cluster.eks_cluster.certificate_authority[0].data
    eks_cidr                          = local.eks_cidr
  })

  bottlerocket_userdata_path = "${path.module}/templates/userdata-bottlerocket.toml"
  bottlerocket_userdata      = templatefile(local.bottlerocket_userdata_path, {
    cluster_id                        = aws_eks_cluster.eks_cluster.id
    apiserver_endpoint                = aws_eks_cluster.eks_cluster.endpoint
    cluster_certificate_authority_b64 = aws_eks_cluster.eks_cluster.certificate_authority[0].data
    bootstrap_extra_args              = var.eks_bootstrap_extra_args
    kubelet_extra_args                = var.kubelet_extra_args
    enable_admin_container            = true
    enable_control_container          = true
  })
  
  userdata = var.ami_family == "Bottlerocket" ? local.bottlerocket_userdata : var.ami_family == "AL2023" ? local.al2023_userdata : local.al2_userdata
  ami_family_lower = lower(var.ami_family)
}
