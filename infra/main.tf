provider "aws" {
  region = "us-east-1"
}

# Creación de VPC para PortTrack
resource "aws_vpc" "porttrack_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "porttrack-vpc" }
}

resource "aws_subnet" "porttrack_subnet_a" {
  vpc_id     = aws_vpc.porttrack_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = { Name = "porttrack-subnet-a", Environment = "prod" }
}

# EKS Cluster
resource "aws_iam_role" "eks_cluster_role" {
  name = "PortTrackEKSClusterRole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_eks_cluster" "porttrack" {
  name    = "porttrack-cluster"
  version = "1.27"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = [aws_subnet.porttrack_subnet_a.id]
  }
}

resource "aws_eks_node_group" "porttrack_nodes" {
  cluster_name    = aws_eks_cluster.porttrack.name
  node_group_name = "porttrack-nodes"
  node_role_arn   = aws_iam_role.eks_cluster_role.arn
  subnet_ids      = [aws_subnet.porttrack_subnet_a.id]
  scaling_config {
      desired_size = 3
      max_size     = 5
      min_size     = 3
  }
  ami_type = "AL2_x86_64"
}