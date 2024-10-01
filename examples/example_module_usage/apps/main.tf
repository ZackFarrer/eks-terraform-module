module "eks_apps" {
  source = "git::https://github.com/ZackFarrer/eks-terraform-module.git//apps?ref=main"  

  cluster_name                      = var.cluster_name
  eks_k8s_version                   = var.eks_k8s_version
  eks_cluster_subnet_ids            = var.eks_cluster_subnet_ids
  tags                              = var.tags
  vpc_id                            = var.vpc_id
  ami_id                            = var.ami_id
  ami_architecture                  = var.ami_architecture
  ami_family                        = var.ami_family
  karpenter_nodepool_name           = var.karpenter_nodepool_name
  karpenter_nodeclass_name          = var.karpenter_nodeclass_name
  karpenter_consolidation_policy    = var.karpenter_consolidation_policy
  karpenter_consolidate_after       = var.karpenter_consolidate_after
  karpenter_expire_after            = var.karpenter_expire_after
  karpenter_capacity_type           = var.karpenter_capacity_type
  karpenter_instance_category       = var.karpenter_instance_category
  karpenter_instance_size           = var.karpenter_instance_size
  karpenter_instance_generation     = var.karpenter_instance_generation
  karpenter_bootstrap_extra_args    = var.karpenter_bootstrap_extra_args
  karpenter_kubelet_extra_args      = var.karpenter_kubelet_extra_args
}
