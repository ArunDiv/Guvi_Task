 
provider "aws" {
  region = "ap-south-1"
  alias  = "mumbai"  
}

provider "aws" {
  region = "us-east-1"
  alias  = "virginia"  
}

 
data "aws_ami" "ubuntu_mumbai" {
  provider    = aws.mumbai  
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]  
}

 
data "aws_ami" "ubuntu_virginia" {
  provider    = aws.virginia  
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}


# Mumbai Security Group
resource "aws_security_group" "Guvi_SSH_Mumbai" {
  provider    = aws.mumbai
  name        = "Guvi_SSH_Mumbai"
  description = "Allow SSH inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Guvi_SSH_Mumbai"
  }
}

# Virginia Security Group
resource "aws_security_group" "Guvi_SSH_Virginia" {
  provider    = aws.virginia
  name        = "Guvi_SSH_Virginia"
  description = "Allow SSH inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Guvi_SSH_Virginia"
  }
}

# Mumbai EC2 Instance
resource "aws_instance" "Guvi_Mumbai" {
  provider            = aws.mumbai
  ami                 = data.aws_ami.ubuntu_mumbai.id  
  instance_type       = "t2.micro"
  user_data = file("userdata.tpl")
  
   
  key_name            = "Devops-Web-Server-Key"  

  vpc_security_group_ids = [aws_security_group.Guvi_SSH_Mumbai.id]

  tags = {
    Name = "Guvi_Mumbai"
  }
}

# Virginia EC2 Instance
resource "aws_instance" "Guvi_Virginia" {
  provider            = aws.virginia
  ami                 = data.aws_ami.ubuntu_virginia.id  
  instance_type       = "t2.micro"
  user_data = file("userdata.tpl")

   
  key_name            = "Devops-Project"  

  vpc_security_group_ids = [aws_security_group.Guvi_SSH_Virginia.id]

  tags = {
    Name = "Guvi_Virginia"
  }
}

 
output "mumbai_instance_id" {
  description = "ID of the EC2 instance launched in Mumbai"
  value       = aws_instance.Guvi_Mumbai.id
}

output "mumbai_public_ip" {
  description = "Public IP of the EC2 instance launched in Mumbai"
  value       = aws_instance.Guvi_Mumbai.public_ip
}

output "virginia_instance_id" {
  description = "ID of the EC2 instance launched in Virginia"
  value       = aws_instance.Guvi_Virginia.id
}

output "virginia_public_ip" {
  description = "Public IP of the EC2 instance launched in Virginia"
  value       = aws_instance.Guvi_Virginia.public_ip
}
