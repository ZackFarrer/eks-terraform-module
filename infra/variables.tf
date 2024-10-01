variable "cluster_name" {
    description = "Name of the EKS cluster"
    type        = string
}

variable "eks_k8s_version" {
    description = "Kubernetes version of the EKS cluster"
    type        = string
}

variable "eks_oidc_provider_openid_connect_client_list" {
    description = "List of OpenID Connect client IDs to add to IRSA provider"
    type        = list(string)
    default     = []
}

variable "eks_oidc_provider_thumbprint_list" {
    description = "List of server certificate thumbprints for the OIDC server cerificates"
    type        = list(string)
    default     = []
}

variable "eks_cluster_subnet_ids" {
    description = "Subnet ids the EKS cluster is built in"
    type        = list(string)
    validation {
      condition     = length(var.eks_cluster_subnet_ids) > 2
      error_message = "list of subnet ids must be passed in and there must be at least 3 subnets"
    }
}

variable "eks_control_plane_log_types" {
    description = "The control plane log types to be enabled"
    type        = list(string)
    default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "tags" {
    description = "A mapping of custom tags to be applied to all resources"
    type        = map(string)
    default     = {}
}

variable "eks_support_type" {
    description = "Support type to use for the cluster. If the cluster is set to EXTENDED, it will enter extended support at the end of standard support. If the cluster is set to STANDARD, it will be automatically upgraded at the end of standard support."
    type        = string
    default     = "EXTENDED"
}

variable "coredns_config" {
    description = "Custom configuration for coredns EKS managed addon"
    type        = map(any)
    default     = {}
}

variable "vpc_cni_config" {
    description = "Custom configuration for vpc-cni EKS managed addon"
    type        = map(any)
    default     = {}
}

variable "kube_proxy_config" {
    description = "Custom configuration for kube-proxy EKS managed addon"
    type        = map(any)
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

variable "eks_cluster_access_entries_and_associations" {
    description = "Map of extra access entries and policy associations to be added for the cluster"
    type        = map(object({
        principal_arn                       = string
        kubernetes_groups                   = list(string)
        policy_association_arn              = string
        association_access_scope_type       = string
        association_access_scope_namespaces = list(string)
    }))
    default = {}
}

variable "eks_nodegroup_labels" {
    description = "Map of kubernetes labels to be applied to the EKS Node Group"
    type        = map(string)
    default     = {}
}

variable "eks_nodegroup_capacity_type" {
    description = "Capacity type for the EKS Node Group"
    type        = string
    default     = "ON_DEMAND"
}

variable "eks_nodegroup_instance_types" {
    description = "Instance types for the EKS Node Group"
    type        = list(string)  
}

variable "eks_nodegroup_force_update_version" {
    description = "Force Update version for the EKS Node Group"
    type        = bool
    default     = false
}

variable "eks_nodegroup_update_config" {
    description = "Update configuration for the EKS Node Group"
    type        = object({
      max_unavailable_percentage = number
    })
    default = {
      max_unavailable_percentage = 33
    }
}

variable "eks_nodegroup_block_device_mappings" {
    description = "List of EBS block device mappings for the EKS Node Group"
    type        = list(object({
        device_name = string
        ebs         = object({
          delete_on_termination = optional(bool, null)
          iops                  = optional(number, null)
          snapshot_id           = optional(string,null)
          throughput            = optional(number, null)
          volume_size           = number
        })
        no_device    = optional(bool, null)
        virtual_name = optional(string, null)
    }))
    default = []
}

variable "eks_nodegroup_enable_monitoring" {
    description = "Enable monitoring for the EKS Node Group"
    type        = bool
    default     = false
}

variable "eks_nodegroup_bootstrap_extra_args" {
    description = "Extra arguments for the EKS Node Group bootstrap script"
    type        = string
    default     = ""  
}

variable "eks_nodegroup_kubelet_extra_args" {
    description = "Extra arguments for the kubelet configuration"
    type        = string
    default     = ""  
}








