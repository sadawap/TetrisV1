# create role
resource "aws_iam_role" "noderole" {
  name = "eks-node-group-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

# Attach policy
resource "aws_iam_role_policy_attachment" "p1-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.noderole.name
}

resource "aws_iam_role_policy_attachment" "p2-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.noderole.name
}

resource "aws_iam_role_policy_attachment" "p3-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.noderole.name
}

# create nodes
resource "aws_eks_node_group" "nodeserver" {
  cluster_name    = aws_eks_cluster.myekscloud.name
  node_group_name = "nodeserver"
  node_role_arn   = aws_iam_role.noderole.arn
  subnet_ids      = data.aws_subnets.public.ids

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 2
  }
  instance_types = [ "t2.micro"]

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.p1-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.p2-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.p3-AmazonEC2ContainerRegistryReadOnly,
  ]
}