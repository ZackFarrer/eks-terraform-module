data "aws_ami" "ami_name" {
    count       = length(var.ami_id) == 0 ? 1 : 0
    most_recent = true
    owners      = [local.account_id]
    
    filter {
      name   = "name"
      values = ["ami-${local.ami_family_lower}-${var.eks_k8s_version}-${var.ami_architecture}*"]
    }
}