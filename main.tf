provider "aws" {
  version = "~> 5.0"
  region  = "ap-southeast-1"
}

resource "aws_vpc" "vpc_devops1" {
  cidr_block = "172.12.0.0/23"
  tags = {
    Name = "vpc_devops1"
  }
}

# Create first subnet
resource "aws_subnet" "subnet_devops1" {
  vpc_id                  = aws_vpc.vpc_devops1.id
  cidr_block              = "172.12.0.0/24"
  availability_zone       = "ap-southeast-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet_devops1"
  }
}

# Create subnet 2
resource "aws_subnet" "subnet_devops2" {
  vpc_id                  = aws_vpc.vpc_devops1.id
  cidr_block              = "172.12.1.0/24"
  availability_zone       = "ap-southeast-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet_devops2"
  }
}

# Create Security Group
resource "aws_security_group" "devops_sg" {
  vpc_id = aws_vpc.vpc_devops1.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["YOUR_IP_ADDRESS/32"] # Replace with your IP address
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devops_sg"
  }
}

# Create EC2 Instance
resource "aws_instance" "devops_instance" {
  ami           = "ami-0ac80df6eff0e70b5" # Amazon Linux 2 AMI in ap-southeast-1 (use the correct AMI ID)
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.subnet_devops2.id
  security_group_ids = [aws_security_group.devops_sg.id]
  
  key_name = "YOUR_SSH_KEY_NAME" # Replace with your SSH key name

  tags = {
    Name = "devops_instance"
  }

  # Associate with Elastic IP (if desired)
  associate_public_ip_address = true
}

# Create S3 bucket to store Terraform state
resource "aws_s3_bucket" "terraform_state" {
  bucket = "devops-terraform-state-bucket"
  acl    = "private"
}

# Enable Terraform remote state backend
terraform {
  backend "s3" {
    bucket = "devops-terraform-state-bucket"
    key    = "state/terraform.tfstate"
    region = "ap-southeast-1"
  }
}
