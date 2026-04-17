resource "aws_vpc" "kubernetes_vpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

    tags = {
        Name = var.vpc_name
    }
}

#############################
# Subnets
#############################

resource "aws_subnet" "public_subnet" {

    vpc_id            = aws_vpc.kubernetes_vpc.id
    cidr_block        = var.public_subnet_cidr
    availability_zone = var.public_subnet_az
    map_public_ip_on_launch = true

    tags={
        Name = "${var.public_subnet_name}"
    }
}

resource "aws_subnet" "private_subnet" {

    vpc_id            = aws_vpc.kubernetes_vpc.id
    cidr_block        = var.private_subnet_cidr
    availability_zone = var.private_subnet_az

    tags= {
        Name = "${var.private_subnet_name}"
    }
}

#############################
# Internet Gateway and Route Table
#############################

resource "aws_internet_gateway" "kubernetes_igw" {
    vpc_id = aws_vpc.kubernetes_vpc.id

    tags = {
        Name = "kubernetes-igw"
    }
}

resource "aws_eip" "kubernetes_eip" {
    domain = "vpc"

    tags = {
        Name = "kubernetes-eip"
    }
}

resource "aws_nat_gateway" "kubernetes_nat_gw" {
    allocation_id = aws_eip.kubernetes_eip.id
    subnet_id     = aws_subnet.public_subnet.id

    tags = {
        Name = "kubernetes-nat-gw"
    }
}

resource "aws_route_table" "public_route_table" {
    vpc_id = aws_vpc.kubernetes_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.kubernetes_igw.id
    }

    tags= {
        Name = "kubernetes-public-route-table"
    }
}

resource "aws_route_table" "private_route_table" {
    vpc_id = aws_vpc.kubernetes_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.kubernetes_nat_gw.id
    }

    tags= {
        Name = "kubernetes-private-route-table"
    }
}

resource "aws_route_table_association" "public_subnet_association" {
    subnet_id      = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.public_route_table.id
}   

resource "aws_route_table_association" "private_subnet_association" {
    subnet_id      = aws_subnet.private_subnet.id
    route_table_id = aws_route_table.private_route_table.id
}


#############################
# Security Group
#############################

resource "aws_security_group" "kubernetes_sg" {
  name        = "kubernetes-control-plane-sg"
  description = "Security group for Kubernetes control plane"
  vpc_id      = aws_vpc.kubernetes_vpc.id

  tags = {
    Name = "kubernetes-control-plane-sg"
  }
}

resource "aws_security_group" "node_sg" {
  name        = "eks-node-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = aws_vpc.kubernetes_vpc.id

  tags = {
    Name = "eks-node-sg"
  }
}

# ---- Control Plane Rules ----
resource "aws_security_group_rule" "control_plane_ingress" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.kubernetes_sg.id
  source_security_group_id = aws_security_group.node_sg.id
}

resource "aws_security_group_rule" "control_plane_egress" {
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.kubernetes_sg.id
  source_security_group_id = aws_security_group.node_sg.id
}

# ---- Worker Node Rules ----
resource "aws_security_group_rule" "node_ingress_443" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.node_sg.id
  source_security_group_id = aws_security_group.kubernetes_sg.id
}

resource "aws_security_group_rule" "node_ingress_kubelet" {
  type                     = "ingress"
  from_port                = 10250
  to_port                  = 10250
  protocol                 = "tcp"
  security_group_id        = aws_security_group.node_sg.id
  source_security_group_id = aws_security_group.kubernetes_sg.id
}

resource "aws_security_group_rule" "node_ingress_self" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.node_sg.id
  self              = true
}

resource "aws_security_group_rule" "node_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.node_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}
