# create a role for Jenkins-access
resource "aws_iam_role" "jenkins-access" {
  name = "Jenkins-terraform"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  
 assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "jenkins-attach" {
  role       = aws_iam_role.jenkins-access.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# create profile for Jenkins
resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "Jenkins-terraform"
  role = aws_iam_role.jenkins-access.name
}

# Create security group for Jenkins
resource "aws_security_group" "Jenkins-sg" {
  name        = "Jenkins-Security Group"
  description = "Open 22,443,80,8080,9000"

  # Define a single ingress rule to allow traffic on all specified ports
  ingress = [
    for port in [22, 80, 443, 8080, 9000, 3000] : {
      description      = "TLS from VPC"
      from_port        = port
      to_port          = port
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Jenkins-sg"
  }
}

# create Jenkins instance
resource "aws_instance" "web" {
  ami                    = "ami-0f5ee92e2d63afc18"
  instance_type          = "t2.large"
  key_name               = "Lenovo_key"
  vpc_security_group_ids = [aws_security_group.Jenkins-sg.id]
  user_data              = templatefile("./install_jenkins.sh", {})

  tags = {
    Name = "Jenkins-EKS"
  }
  root_block_device {
    volume_size = 30
  }
}