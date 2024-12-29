provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  cluster_name = "ea-hub-eks-kindarian"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

# VPC with private subnets only
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

  name = "ea-hub-vpc"

  cidr = "10.0.0.0/16"
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.5"

  cluster_name    = local.cluster_name
  cluster_version = "1.31"

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  enable_cluster_creator_admin_permissions = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }

  # Single node group with private subnets only
  eks_managed_node_groups = {
    private-group = {
      name           = "private-node-group"
      instance_types = ["t3.small"]
      subnet_ids     = module.vpc.private_subnets

      min_size     = 1
      max_size     = 3
      desired_size = 2
    }
  }
}

# IAM Role for AWS Load Balancer Controller
module "irsa_lb_controller" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "5.39.0"

  create_role                   = true
  role_name                     = "${local.cluster_name}-lb-controller"
  provider_url                  = module.eks.oidc_provider
  role_policy_arns              = ["arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
}


data "aws_secretsmanager_secret" "password" {
  name = "ea-hub-db-password"
}

data "aws_secretsmanager_secret_version" "password_version" {
  secret_id = data.aws_secretsmanager_secret.password.id
}

resource "aws_db_subnet_group" "ea-hub" {
  name       = "ea-hub-subnet-group"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = "ea-hub-rds"
  }
}

resource "aws_security_group" "rds" {
  name   = "ea-hub-rds"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ea-hub-rds"
  }
}

resource "aws_db_parameter_group" "ea-hub" {
  name   = "ea-hub"
  family = "postgres14"

  parameter {
    name  = "log_connections"
    value = "1"
  }
}

resource "aws_db_instance" "ea-hub" {
  identifier             = "ea-hub"
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "14.15"
  username               = "eahubdbuser"
  password               = jsondecode(data.aws_secretsmanager_secret_version.password_version.secret_string).password
  db_subnet_group_name   = aws_db_subnet_group.ea-hub.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.ea-hub.name
  publicly_accessible    = false
  skip_final_snapshot    = true
}


