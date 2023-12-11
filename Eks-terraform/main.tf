# create a Policy
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# create a role
resource "aws_iam_role" "eks_role" {
  name               = "ekscluster_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Attach a policy with role
resource "aws_iam_role_policy_attachment" "eks_role-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_role.name
}

# Collect VPC default data
data "aws_vpc" "default" {
    default = true
}

# Get Public subnet
data "aws_subnets" "public" {
    filter {
      name = "vpc-id"
      values = [data.aws_vpc.default.id]
    }
}
# Create EKS cluster
resource "aws_eks_cluster" "myekscloud" {
  name     = "myekscloud"
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids = data.aws_subnets.public.ids
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.eks_role-AmazonEKSClusterPolicy,
  ]
}