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

