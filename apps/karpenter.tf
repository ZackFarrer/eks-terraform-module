resource "helm_release" "karpenter" {
    name             = "karpenter"
    namespace        = "karpenter"
    create_namespace = true
    chart            = "karpenter"
    version          = "1.0.3"
    repository       = "oci://${local.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com"
    atomic           = true
    cleanup_on_fail  = true
    values           = [local.karpenter_helm_values]
}

resource "kubectl_manifest" "nodepool" {
    yaml_body = templatefile("${path.module}/templates/node-pool.yaml", {
        node_pool_name       = var.karpenter_nodepool_name,
        node_class_name      = var.karpenter_nodeclass_name,
        consolidation_policy = var.karpenter_consolidation_policy,
        consolidate_after    = var.karpenter_consolidate_after,
        expire_after         = var.karpenter_expire_after,
        capacity_type        = var.karpenter_capacity_type,
        instance_category    = var.karpenter_instance_category,
        instance_size        = var.karpenter_instance_size,
        instance_generation  = var.karpenter_instance_generation,
    })

    depends_on = [helm_release.karpenter]
}

# Pause terraform execution to allow karpenter to provision nodes
resource "null_resource" "allow_time_for_karpenter_node_provisioning" {
    provisioner "local-exec" {
      command = "sleep 60"
    }
    
    depends_on = [kubectl_manifest.nodepool]
}

resource "kubectl_manifest" "nodeclass_al2023" {
    count     = var.ami_family == "AL2023" ? 1 : 0
    yaml_body = templatefile("${path.module}/templates/node-class-al2023.yaml", {
        node_class_name                   = var.karpenter_nodeclass_name,
        ami_family                        = var.ami_family,
        ami_id                            = local.ami_id,
        karpenter_role                    = data.aws_iam_role.eks_nodegroup_role.arn,
        apiserver_endpoint                = data.aws_eks_cluster.eks_cluster.endpoint,
        cluster_id                        = data.aws_eks_cluster.eks_cluster.id,
        eks_cidr                          = local.eks_cidr,
        cluster_certificate_authority_b64 = data.aws_eks_cluster.eks_cluster.certificate_authority[0].data,
        cluster_sg_id                     = data.aws_security_group.eks_nodegroup_sg.id,
        subnet_id1                        = var.eks_cluster_subnet_ids[0],
        subnet_id2                        = var.eks_cluster_subnet_ids[1],
        subnet_id3                        = var.eks_cluster_subnet_ids[2]
    })

    depends_on = [helm_release.karpenter]
}

resource "kubectl_manifest" "nodeclass_al2" {
    count     = var.ami_family == "AL2" ? 1 : 0
    yaml_body = templatefile("${path.module}/templates/node-class-al2.yaml", {
        node_class_name                   = var.karpenter_nodeclass_name,
        ami_family                        = var.ami_family,
        ami_id                            = local.ami_id,
        karpenter_role                    = data.aws_iam_role.eks_nodegroup_role.arn,
        apiserver_endpoint                = data.aws_eks_cluster.eks_cluster.endpoint,
        cluster_id                        = data.aws_eks_cluster.eks_cluster.id,
        cluster_certificate_authority_b64 = data.aws_eks_cluster.eks_cluster.certificate_authority[0].data,
        cluster_sg_id                     = data.aws_security_group.eks_nodegroup_sg.id,
        subnet_id1                        = var.eks_cluster_subnet_ids[0],
        subnet_id2                        = var.eks_cluster_subnet_ids[1],
        subnet_id3                        = var.eks_cluster_subnet_ids[2],
        bootstrap_extra_args              = var.karpenter_bootstrap_extra_args,
        kubelet_extra_args                = var.karpenter_kubelet_extra_args
    })

    depends_on = [helm_release.karpenter]
}

resource "kubectl_manifest" "nodeclass_bottlerocket" {
    count     = var.ami_family == "Bottlerocket" ? 1 : 0
    yaml_body = templatefile("${path.module}/templates/node-class-bottlerocket.yaml", {
        node_class_name                   = var.karpenter_nodeclass_name,
        ami_family                        = var.ami_family,
        ami_id                            = local.ami_id,
        karpenter_role                    = data.aws_iam_role.eks_nodegroup_role.arn,
        apiserver_endpoint                = data.aws_eks_cluster.eks_cluster.endpoint,
        cluster_id                        = data.aws_eks_cluster.eks_cluster.id,
        cluster_certificate_authority_b64 = data.aws_eks_cluster.eks_cluster.certificate_authority[0].data,
        cluster_sg_id                     = data.aws_security_group.eks_nodegroup_sg.id,
        enable_admin_container            = true
        enable_control_container          = true
        subnet_id1                        = var.eks_cluster_subnet_ids[0],
        subnet_id2                        = var.eks_cluster_subnet_ids[1],
        subnet_id3                        = var.eks_cluster_subnet_ids[2],
        bootstrap_extra_args              = var.karpenter_bootstrap_extra_args,
    })

    depends_on = [helm_release.karpenter]
}

