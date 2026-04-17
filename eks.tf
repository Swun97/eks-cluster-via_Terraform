resource "aws_eks_cluster" "kubernetes_cluster" {
  name     = "kubernetes-cluster"
  version = "1.35"
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    endpoint_public_access = true
    endpoint_private_access = true
    subnet_ids = [aws_subnet.public_subnet.id, aws_subnet.private_subnet.id]
    security_group_ids = [aws_security_group.kubernetes_sg.id]
  }
}

resource "aws_eks_node_group" "kubernetes_public_node_group" {
  cluster_name    = aws_eks_cluster.kubernetes_cluster.name
  node_group_name = "kubernetes-public-node-group"
  node_role_arn   = aws_iam_role.node_group.arn
  subnet_ids      = [aws_subnet.public_subnet.id]

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  instance_types = ["t3.small"]

  tags = {
    Name = "kubernetes-public-node-group"
  }
}

resource "aws_eks_node_group" "kubernetes_private_node_group" {
  cluster_name    = aws_eks_cluster.kubernetes_cluster.name
  node_group_name = "kubernetes-private-node-group"
  node_role_arn   = aws_iam_role.node_group.arn
  subnet_ids      = [aws_subnet.private_subnet.id]

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  instance_types = ["t3.small"]

  tags = {
    Name = "kubernetes-private-node-group"
  }
}
