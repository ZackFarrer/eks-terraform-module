data "aws_ami" "public_ami" {
    count       = length(var.ami_id) == 0 ? 1 : 0
    most_recent = true
    owners      = ["941016683700"]
    
    filter {
        name   = "name"
        values = [var.public_ami_search_filter]
        }
}

resource "aws_ami_copy" "name" {
    count             = length(var.ami_id) == 0 ? 1 : 0
    name              = "ami-${local.ami_family_lower}-${var.eks_k8s_version}-${var.ami_architecture}-${timestamp()}"
    source_ami_id     = data.aws_ami.public_ami.id
    source_ami_region = data.aws_region.current.name

    tags              = var.tags
}


data "aws_ami" "ami_name" {
    count       = length(var.ami_id) == 0 ? 1 : 0
    most_recent = true
    owners      = [local.account_id]
    
    filter {
      name   = "name"
      values = ["ami-${local.ami_family_lower}-${var.eks_k8s_version}-${var.ami_architecture}*"]
    }
}