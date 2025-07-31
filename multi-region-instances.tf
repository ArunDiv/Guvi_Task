terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
    region = "ap-south-1"
     
}

provider "aws" {
    alias  = "virginia"
    region = "us-east-1"
  
}

data "aws_ami" "ubuntu_mumbai" {
    provider = aws
    most_recent = true
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "Guvi_Mumbai" {
    provider = aws
    ami = data.aws_ami.ubuntu_mumbai.id
    instance_type = "t2.micro"

}

data "aws_ami" "ubuntu_Virginia" {
    provider = aws.virginia
    most_recent = true
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "Guvi_Virginia" {
    provider = aws.virginia
    ami = data.aws_ami.ubuntu_Virginia.id
    instance_type = "t2.micro"

}

output "ubuntu_mumbai_ami_id" {
  description = "Latest Ubuntu AMI ID in ap-south-1 (Mumbai)"
  value       = data.aws_ami.ubuntu_mumbai.id
}

output "ubuntu_virginia_ami_id" {
  description = "Latest Ubuntu AMI ID in us-east-1 (Virginia)"
  value       = data.aws_ami.ubuntu_Virginia.id
}


