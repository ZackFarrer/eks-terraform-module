resource "aws_security_group" "eks_nodegroup_sg" {
    name_prefix = "${var.cluster_name}-nodegroup-sg"
    vpc_id      = var.vpc_id
    tags = merge(
        { Name = "${var.cluster_name}-nodegroup-sg"},
        var.tags
    )
}

resource "aws_vpc_security_group_ingress_rule "eks_nodegroup_to_control_plane_ingress" {
    security_group_id            = aws_security_group.eks_nodegroup_sg.id
    ip_protocol                  = "-1"
    description                  = "Allow all communication between worker nodes and control plane"
    referenced_security_group_id = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
}

resource "aws_vpc_security_group_ingress_rule "eks_nodegroup_sg_self_ingress" {
    security_group_id            = aws_security_group.eks_nodegroup_sg.id
    ip_protocol                  = "-1"
    description                  = "Allow all communication between worker nodes"
    referenced_security_group_id = aws_security_group.eks_nodegroup_sg.id
}

resource "aws_vpc_security_group_egress_rule "eks_nodegroup_sg_egress" {
    security_group_id            = aws_security_group.eks_nodegroup_sg.id
    ip_protocol                  = "-1"
    description                  = "Allow all traffic to leave worker nodes"
    referenced_security_group_id = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule "eks_control_plane_to_nodegroup_ingress" {
    security_group_id            = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
    ip_protocol                  = "-1"
    description                  = "Allow all communication between worker nodes and control plane"
    referenced_security_group_id = aws_security_group.eks_nodegroup_sg.id
}

resource "aws_eks_node_group" "eks_nodegroups" {

    cluster_name           = var.cluster_name
    node_group_name_prefix = "${var.cluster_name}-ng"
    node_role_arn          = aws_iam_role.eks_nodegroup_iam_role.arn
    subnet_ids             = var.eks_cluster_subnet_ids
    ami_type               = "CUSTOM"
    labels                 = var.eks_worker_node_labels
    capacity_type          = var.eks_worker_node_capacity_type
    instance_types         = var.eks_worker_node_instance_types

    scaling_config {
        desired_size = 3
        max_size     = 6
        min_size     = 3
    }

    launch_template {
        version = aws_launch_template.eks_nodegroup_launch_template.latest_version
        id      = aws_launch_template.eks_nodegroup_launch_template.id
    }

    # Only schedule Karpenter pods on the nodes in this nodegroup
    taint {
        key    = "karpenter"
        value  = "true"
        effect = "NO_SCHEDULE"
    }

    force_force_update_version = var.eks_nodegroup_force_update_version

    dynamic "update_config" {
        for_for_each = length(var.eks_nodegroup_update_config) > 0 ? [var.eks_nodegroup_update_config] : []

        content {
            max_unavailable_percentage = try(update_config.value.max_unavailable_percentage, null)
        }
    }
       
    tags = var.tags

    lifecyle {
        ignore_change         = [scaling_config]
        create_before_destroy = true
    }

    # Just like the EKS cluster ensure IAM resources are created before and deleted after the eks node group resource
    depends_on = [
        aws_iam_role_policy_attachment.eks_nodegroup_role_policy_attachments,
        aws_eks_access_entry.nodegroup-role-access-entry,
        aws_eks_cluster.eks_cluster
    ]
}