resource "aws_security_group" "eks_nodegroup_sg" {
    name_prefix = "${var.cluster_name}-nodegroup-sg"
    vpc_id      = var.vpc_id
    tags = merge(
        { Name = "${var.cluster_name}-nodegroup-sg"},
        var.tags
    )
}

resource "aws_vpc_security_group_ingress_rule" "eks_nodegroup_to_control_plane" {
    security_group_id            = aws_security_group.eks_nodegroup_sg.id
    ip_protocol                  = "-1"
    description                  = "Allow communication between worker nodes and control plane"
    referenced_security_group_id = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
}

resource "aws_vpc_security_group_ingress_rule" "control_plane_to_nodegroup" {
    security_group_id            = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_i
    ip_protocol                  = "-1"
    description                  = "Allow communication between worker nodes and control plane"
    referenced_security_group_id = aws_security_group.eks_nodegroup_sg.id
}

resource "aws_vpc_security_group_ingress_rule" "eks_nodegroup_self" {
    security_group_id            = aws_security_group.eks_nodegroup_sg.id
    ip_protocol                  = "-1"
    description                  = "Enable communication between worker nodes"
    referenced_security_group_id = aws_security_group.eks_nodegroup_sg.id
}


resource "aws_eks_node_group" "eks_nodegroups" {

    cluster_name           = var.cluster_name
    node_group_name_prefix = "${var.cluster_name}-ng"
    node_role_arn          = aws_iam_role.eks_nodegroup_iam_role.arn
    subnet_ids             = var.eks_cluster_subnet_ids
    ami_type               = "CUSTOM"
    labels                 = var.eks_nodegroup_labels
    capacity_type          = var.eks_nodegroup_capacity_type
    instance_types         = var.eks_nodegroup_instance_types

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

    force_update_version = var.eks_nodegroup_force_update_version

    dynamic "update_config" {
        for_each = length(var.eks_nodegroup_update_config) > 0 ? [var.eks_nodegroup_update_config] : []

        content {
            max_unavailable_percentage = try(update_config.value.max_unavailable_percentage, null)
        }
    }
       
    tags = var.tags

    lifecycle {
        ignore_changes        = [scaling_config]
        create_before_destroy = true
    }

    # Just like the EKS cluster ensure IAM resources are created before and deleted after the eks node group resource
    depends_on = [
        aws_iam_role_policy_attachment.eks_nodegroup_role_policy_attachments,
        aws_eks_access_entry.nodegroup-role-access-entry,
        aws_eks_cluster.eks_cluster
    ]
}

resource "aws_launch_template" "eks_nodegroup_launch_template" {
    name_prefix            = "${var.cluster_name}-ng-lt"
    update_default_version = true
    image_id               = local.ami_id
    ebs_optimized          = true

    # Block device mappings vary across node types but we enforce encryption and gp3
    dynamic "block_device_mappings" {
        for_each = var.eks_nodegroup_block_device_mappings

        content {
            device_name = try(block_device_mappings.value.device_name, null)
        
            
            dynamic "ebs" {
                for_each = try([block_device_mappings.value.ebs], [])
                content {
                    delete_on_termination = try(ebs.value.delete_on_termination, null)
                    iops                  = try(ebs.value.iops, null)
                    snapshot_id           = try(ebs.value.snapshot_id, null)
                    throughput            = try(ebs.value.throughput, null)
                    volume_size           = try(ebs.value.volume_size, null)
                    volume_type           = "gp3"
                    encrypted             = true
                }
            }
            no_device    = try(block_device_mappings.value.no_device, null)
            virtual_name = try(block_device_mappings.value.virtual_name, null)
        }
    }

    network_interfaces {
        associate_public_ip_address = false
        security_groups             = [aws_security_group.eks_nodegroup_sg.id]
    }
    
    # Enforce metadata config to ensure SSM works correctly
    metadata_options {
        http_endpoint                   = "enabled"
        http_tokens                     = "required"
        http_put_response_hop_limit     = 1
        instance_metadata_tags = "enabled"
    }

    dynamic "monitoring" {
        for_each = var.eks_nodegroup_enable_monitoring ? [1] : []

        content {
            enabled = var.eks_nodegroup_enable_monitoring
        }
    }

    user_data = base64encode(local.userdata)

    tag_specifications {
        resource_type = "instance"
        tags          = local.combined_default_and_data_tags
    }

    tag_specifications {
        resource_type = "volume"
        tags          = local.combined_default_and_data_tags
    }

    tags = var.tags
}

data "aws_iam_policy_document" "eks_nodegroup_assume_role_policy_document" {
    statement {
        effect  = "Allow"
        actions = ["sts:AssumeRole"]
        principals {
            type        = "Service"
            identifiers = ["ec2.amazonaws.com"]
          
        }
    }
}

resource "aws_iam_role" "eks_nodegroup_iam_role" {
    name                  = "${var.cluster_name}-ng-role"
    description           = "${var.cluster_name} EKS Node Group IAM role"
    force_detach_policies = true
    assume_role_policy    = data.aws_iam_policy_document.eks_nodegroup_assume_role_policy_document.json
    tags                  = var.tags
}

resource "aws_iam_instance_profile" "eks_nodegroup_instance_profile" {
    name = "${var.cluster_name}-ng-instance-profile"
    role = aws_iam_role.eks_nodegroup_iam_role
    tags = var.tags
}

resource "aws_iam_role_policy_attachment" "eks_nodegroup_role_policy_attachments" {
    for_each = { for k, v in toset(compact([
      "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
      "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
      "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
      "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    ])) : k => v }

    policy_arn = each.value
    role       = aws_iam_role.eks_nodegroup_iam_role.name
}