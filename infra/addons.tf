data "aws_eks_addon_version" "vpc_cni" {
    addon_name         = "vpc-cni"
    kubernetes_version = var.eks_k8s_version
    most_recent        = true
}

data "aws_eks_addon_version" "kube_proxy" {
    addon_name         = "kube-proxy"
    kubernetes_version = var.eks_k8s_version
    most_recent        = true
}

data "aws_eks_addon_version" "coredns" {
    addon_name         = "coredns"
    kubernetes_version = var.eks_k8s_version
    most_recent        = true
}

resource "aws_eks_addon" "vpc_cni" {
    cluster_name                = var.cluster_name
    addon_name                  = "vpc-cni"
    addon_version               = data.aws_eks_addon_version.vpc_cni.version
    configuration_values        = jsonencode(var.vpc_cni_config)
    preserve                    = true
    resolve_conflicts_on_create = "OVERWRITE"
    resolve_conflicts_on_update = "OVERWRITE"

    depends_on = [aws_eks_cluster.eks_cluster]
}

resource "aws_eks_addon" "kube_proxy" {
    cluster_name                = var.cluster_name
    addon_name                  = "kube-proxy"
    addon_version               = data.aws_eks_addon_version.kube_proxy.version
    configuration_values        = jsonencode(var.kube_proxy_config)
    preserve                    = true
    resolve_conflicts_on_create = "OVERWRITE"
    resolve_conflicts_on_update = "OVERWRITE"

    depends_on = [aws_eks_cluster.eks_cluster]
}

resource "aws_eks_addon" "coredns" {
    cluster_name                = var.cluster_name
    addon_name                  = "coredns"
    addon_version               = data.aws_eks_addon_version.coredns.version
    preserve                    = true
    resolve_conflicts_on_create = "OVERWRITE"
    resolve_conflicts_on_update = "OVERWRITE"
    # Merge optional config with enforced toleration to ensure coredns pods run in managaed node group running karpenter pods
    configuration_values        = jsonencode(
     merge(
        {
          tolerations = [
            {
              key      = "karpenter"
              operator = "Equal"
              value    = "true"
              effect   = "NoSchedule"
            }
          ]
        },
        var.coredns_config
     )
    )

    depends_on = [aws_eks_cluster.eks_cluster]
}




