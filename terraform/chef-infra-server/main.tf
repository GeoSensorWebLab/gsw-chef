# Most resources will be in Oregon (US-West-2)
provider "aws" {
  allowed_account_ids = ["546905020646"]
  profile             = "gswlab"
  region              = "us-west-2"
  version             = "~> 3.0"
}

# Some resources must be in the "global" region
provider "aws" {
  alias               = "awseast"
  allowed_account_ids = ["546905020646"]
  profile             = "gswlab"
  region              = "us-east-1"
  version             = "~> 3.0"
}

########################
# Key Management Service
########################

resource "aws_kms_key" "chef_key" {
  description = "KMS key for Chef Infra Server"
  
  tags = {
    terraform = "chef-infra-server"
  }
}

#####
# IAM
#####

# This profile will allow other AWS resources to grant access to EC2
# instances using this profile, instead of having to deploy keys to
# services running on the instance.
resource "aws_iam_instance_profile" "chef_server_profile" {
  name = "chef_server_profile"
  role = aws_iam_role.chef_role.name
}

resource "aws_iam_role" "chef_role" {
  name = "chef_role"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF

  tags = {
    terraform = "chef-infra-server"
  }
}

#####
# EC2
#####

resource "aws_key_pair" "gswlab_key" {
  key_name   = "gswlab-aws-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/OgHlCLxG4R99ln/llXYi78O6rnR2KXnhO9U6pqV+LSzAgQQ97VYXoXHQ8RBnsJbfO2V8Ii/SCVJDODXqsaFC1q3VLlZkLzLD9wFYKOsiKGgEq6zzuEbQC2hossClg1j/9oDFuN8DikkWM7gPOysLPo6NwfMkgjm7hLNt2/JTKXoOavXAp6QFi5RPSshK7POcPS3JYKmFTWT9C8mHMS7TMr744J/88/lqims0xsDAoSTJp47KqLi2SXVf7GVttNRrmSpexMvZVtoUVm2Ijv6J0FtR/O6J+qY7IulwxW/WBjcVRTFbEsb4GgPbAWntLMLsFF+8nf20gkj/J9rKT7nj gswlab-aws"

  tags = {
    terraform = "chef-infra-server"
  }
}

resource "aws_security_group" "chef_infra_server" {
  name        = "chef_infra_server"
  description = "Allow SSH, HTTP/HTTPS inbound"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    terraform = "chef-infra-server"
  }
}

resource "aws_security_group_rule" "allow_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.chef_infra_server.id
}

resource "aws_security_group_rule" "allow_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.chef_infra_server.id
}

resource "aws_security_group_rule" "allow_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.chef_infra_server.id
}

data "aws_ami" "ubuntu2004" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "chef_server" {
  ami                         = data.aws_ami.ubuntu2004.id
  associate_public_ip_address = true
  hibernation                 = true
  iam_instance_profile        = aws_iam_instance_profile.chef_server_profile.name
  instance_type               = "t2.medium"
  key_name                    = aws_key_pair.gswlab_key.key_name
  vpc_security_group_ids      = [aws_security_group.chef_infra_server.id]

  root_block_device {
    delete_on_termination = true
    encrypted             = true
    kms_key_id            = aws_kms_key.chef_key.id
    volume_size           = 30
    volume_type           = "gp2"
  }

  tags = {
    Name = "ChefInfraServer"
    terraform = "chef-infra-server"
  }
}

output "instance_ip_addr" {
  value       = aws_instance.chef_server.private_ip
  description = "The private IP address of the Chef Infra Server instance."
}

output "instance_pub_ip_addr" {
  value       = aws_instance.chef_server.public_ip
  description = "The public IP address of the Chef Infra Server instance."
}
