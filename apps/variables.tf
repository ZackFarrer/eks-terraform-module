variable "cluster_name" {
    description = "Name of the EKS cluster"
    type        = string
}

variable "eks_k8s_version" {
    description = "Kubernetes version of the EKS cluster"
    type        = string
}

variable "eks_cluster_subnet_ids" {
    description = "Subnet ids the EKS cluster is built in"
    type        = list(string)
    validation {
      condition     = length(var.eks_cluster_subnet_ids) > 2
      error_message = "list of subnet ids must be passed in and there must be at least 3 subnets"
    }
}

variable "tags" {
    description = "A mapping of custom tags to be applied to all resources"
    type        = map(string)
    default     = {}
}

variable "vpc_id" {
    description = "VPC id that the cluster is built in"
    type        = string
}

variable "ami_id" {
    description = "AMI id to be used for nodegroup and karpenter EC2NodeClass nodes"
    type        = string
    default     = ""
}

variable "public_ami_search_filter" {
    description = "Filter to query public AMI which is copied and renamed to fit naming convention in private AMI repo"
    type        = string
}

variable "ami_architecture" {
    description = "AMI architecture to be used for nodegroup and karpenter EC2NodeClass nodes"
    type        = string
}

variable "ami_family" {
    description = "AMI family to be used for nodegroup and karpenter EC2NodeClass nodes"
    type        = string
}

variable "karpenter_nodepool_name" {
    description = "Name of the karpenter nodepool resource"
    type        = string
}

variable "karpenter_nodeclass_name" {
    description = "Name of the karpenter nodeclass resource"
    type        = string
}

variable "karpenter_consolidation_policy" {
    description = "Describes which types of Nodes Karpenter should consider for consolidation. If using 'WhenEmptyOrUnderutilized' Karpenter will consider all nodes for consolidation and attempt to remove or replace Nodes when it discovers that the Node is empty or underutilized and could be changed to reduce cost. If using `WhenEmpty`, Karpenter will only consider nodes for consolidation that contain no workload pods"
    type        = string
}

variable "karpenter_consolidate_after" {
    description = "The amount of time Karpenter should wait to consolidate a node after a pod has been added or removed from the node. You can choose to disable consolidation entirely by setting the string value 'Never'"
    type        = string
}

variable "karpenter_expire_after" {
    description = "The amount of time a node can live on the cluster before being removed can be '720h' or 'Never'"
    type        = string
}

variable "karpenter_capacity_type" {
    description = "Capacity type for nodes karpenter provisions. Can be 'on-demand' or 'spot'"
    type        = list(string)
}

variable "karpenter_instance_category" {
    description = "List of instance categories karpenter will use to provision nodes"
    type        = list(string)
}

variable "karpenter_instance_size" {
    description = "List of instance sizes karpenter will use to provision nodes"
    type        = list(string)
}

variable "karpenter_instance_generation" {
    description = "List of instance generations karpenter will use to provision nodes"
    type        = list(string)
}

variable "karpenter_bootstrap_extra_args" {
    description = "Extra arguments for the bootstrap script for karpenter nodes"
    type        = string
    default     = ""  
}

variable "karpenter_kubelet_extra_args" {
    description = "Extra arguments for the kubelet configuration for karpenter nodes"
    type        = string
    default     = ""  
}









