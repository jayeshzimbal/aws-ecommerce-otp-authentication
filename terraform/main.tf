terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

#################################################
# VPC
#################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "ecommerce-vpc"

  cidr = "10.0.0.0/16"

  azs = [
    "ap-south-1a",
    "ap-south-1b"
  ]

  public_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]

  private_subnets = [
    "10.0.11.0/24",
    "10.0.12.0/24"
  ]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  tags = {
    Project                               = "ecommerce"
    "kubernetes.io/cluster/ecommerce-cluster" = "shared"
  }
}

#################################################
# EKS CLUSTER
#################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "ecommerce-cluster"
  cluster_version = "1.30"

  cluster_endpoint_public_access = true

    vpc_id = module.vpc.vpc_id

  subnet_ids = module.vpc.private_subnets

  control_plane_subnet_ids = module.vpc.private_subnets

  depends_on = [
    module.vpc
  ]


  enable_cluster_creator_admin_permissions = true

  cluster_service_ipv4_cidr = "172.20.0.0/16"

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"

    instance_types = [
      "t3.micro"
    ]
  }

  eks_managed_node_groups = {
    workers = {
      min_size     = 1
      max_size     = 3
      desired_size = 2
    }
  }

  tags = {
    Project = "ecommerce"
  }
}

#################################################
# OUTPUTS
#################################################

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "vpc_id" {
  value = module.vpc.vpc_id
}