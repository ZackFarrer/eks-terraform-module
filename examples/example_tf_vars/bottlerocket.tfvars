cluster_name                      = "my-eks-cluster"
eks_k8s_version                   = "1.30"
eks_cluster_subnet_ids            = ["subnet-12345", "subnet-67890", "subnet-abcde"]
tags                              = {
  Environment = "production"
  Project     = "eks-cluster"
}
vpc_id                            = "vpc-1234567890abcdef"
ami_architecture                  = "x86_64"
ami_family                        = "Bottlerocket"
public_ami_search_filter          = "bottlerocket-aws-k8s-1.30-x86_64*"

karpenter_nodepool_name           = "bottlerocket-nodepool"
karpenter_nodeclass_name          = "bottlerocket-nodeclass"
karpenter_consolidation_policy    = "WhenEmptyOrUnderutilized"
karpenter_consolidate_after       = "5m"
karpenter_expire_after            = "720h"
karpenter_capacity_type           = ["on-demand", "spot"]
karpenter_instance_category       = ["c", "m", "r"]
karpenter_instance_size           = ["large", "xlarge"]
karpenter_instance_generation     = ["3","4","5"]
karpenter_bootstrap_extra_args    = "--some-bootstrap-arg"
karpenter_kubelet_extra_args      = "--some-kubelet-arg"

eks_support_type                              = "EXTENDED"
eks_cluster_access_entries_and_associations   = {
  entry1 = {
    principal_arn                       = "arn:aws:iam::123456789012:role/my-role"
    kubernetes_groups                   = ["system:masters"]
    policy_association_arn              = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    association_access_scope_type       = "CLUSTER"
    association_access_scope_namespaces = ["default", "kube-system"]
  }
}
eks_nodegroup_labels                        = {
  app     = "nginx"
  purpose = "web-server"
}
eks_nodegroup_capacity_type                 = "ON_DEMAND"
eks_nodegroup_instance_types                = ["t3.medium", "t3.large"]
eks_nodegroup_block_device_mappings         = [
  {
    device_name = "/dev/xvda"
    ebs = {
      delete_on_termination = true
      volume_size           = 100
    }
  }
]
eks_nodegroup_enable_monitoring             = true
eks_nodegroup_bootstrap_extra_args          = "--bootstrap-extra"
eks_nodegroup_kubelet_extra_args            = "--kubelet-extra"
