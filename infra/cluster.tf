resource "aws_eks_cluster" "eks_cluster" {
    name                      = var.cluster_name
    version                   = var.eks_k8s_version
    role_arn                  = aws_iam_role.eks_cluster_iam_role.arn
    enabled_cluster_log_types = var.eks_control_plane_log_types

    upgrade_policy {
        support_type = var.eks_support_type
    }

    vpc_config {
      subnet_ids              = var.eks_cluster_subnet_ids
      security_group_ids      = [aws_security_group.eks_nodegroup_sg.id]
      endpoint_private_access = true
      endpoint_public_access  = false
    }

    access_config {
        authentication_mode                         = "API"

        # Role arn creating the cluster is given admin permissions via access entries when true
        bootstrap_cluster_creator_admin_permissions = true
    }

    kubernetes_network_config {
      ip_family         = "ipv4"
    }
    
    tags = merge(
        { Name = var.cluster_name},
        var.tags
    )

    # Ensure IAM resources are created before and deleted after modifying EKS cluster 
    # otherwise EKS will not delete EC2, security groups and associated resources correctly
    depends_on = [aws_iam_role_policy_attachment.eks_cluster_role_default_policy_attachments] 
}

data "aws_iam_policy_document" "eks_cluster_assume_role_policy_document" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_cluster_iam_role" {
    name                  = "${var.cluster_name}-cluster-role"
    force_detach_policies = true
    assume_role_policy    =  data.aws_iam_policy_document.eks_cluster_assume_role_policy_document
    tags                  = var.tags
}

resource "aws_iam_role_policy_attachment" "eks_cluster_role_default_policy_attachments" {
    for_each = { for k, v in toset(compact([
      "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
      "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController",
    ])) : k => v }

    policy_arn = each.value
    role       = aws_iam_role.eks_cluster_iam_role.name
}

# OIDC is required if using IAM roles for Service Accounts (IRSA) but not if using pod identity addon
resource "aws_iam_openid_connect_provider" "eks_oidc_provider" {
    url             = aws_eks_cluster.eks_cluster_identity[0].oidc[0].issuer
    client_id_list  = distinct(concat(var.eks_oidc_provider_openid_connect_client_list, local.default_clientid_list))
    thumbprint_list = distinct(concat(var.eks_oidc_provider_thumbprint_list, local.default_thumbprint_list))
}