# Hardcode minimum access_entries required for cluster
resource "aws_eks_access_entry" "cluster-role-access-entry" {
    cluster_name  = var.cluster_name
    principal_arn = aws_iam_role.eks_cluster_iam_role.arn
    type          = "STANDARD"
    tags          = var.tags

    depends_on = [aws_eks_cluster.eks_cluster]
}

resource "aws_eks_access_policy_association" "cluster-role-access-policy-association" {
    cluster_name  = var.cluster_name
    policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
    principal_arn = aws_iam_role.eks_cluster_iam_role.arn

    access_scope {
        type = "cluster"
    }

    depends_on = [aws_eks_access_entry.cluster-role-access-entry]  
}

resource "aws_eks_access_entry" "nodegroup-role-access-entry" {
    cluster_name  = var.cluster_name
    principal_arn = aws_iam_role.eks_nodegroup_iam_role.arn
    type          = "EC2_LINUX"
    tags          = var.tags

    depends_on = [aws_eks_cluster.eks_cluster]
}

resource "aws_eks_access_entry" "eks_cluster_auth_access_entry" {
    for_each = var.eks_cluster_access_entries_and_associations

    cluster_name  = var.cluster_name
    principal_arn = each.value.principal_arn
    kubernetes_groups = try(each.value.kubernetes_groups, [])
    type              = "STANDARD"
    tags              = var.tags

    depends_on = [aws_eks_cluster.eks_cluster]
}

resource "aws_eks_access_policy_association" "eks_cluster_auth_access_policy_association" {
    for_each = var.eks_cluster_access_entries_and_associations

    cluster_name  = var.cluster_name
    policy_arn    = each.value.policy_association_arn
    principal_arn = each.value.principal_arn

    access_scope {
      type       = each.value.association_access_scope_type
      namespaces = each.value.association_access_scope_type == "namespace" ? try(each.value.association_access_scope_namespaces, []) : null
    }
    
    depends_on = [aws_eks_access_entry.aws_eks_access_entry.eks_cluster_auth_access_entry]
}