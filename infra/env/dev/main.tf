provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "../../modules/vpc"
  vpc_cidr              = var.vpc_cidr

  azs                   = var.aws_region == "us-east-1" ? ["us-east-1a", "us-east-1b", "us-east-1c"] : []
  name_prefix           = var.env
  private_subnet_cidrs  = var.private_subnets
  public_subnet_cidrs   = var.public_subnets
}

module "jenkins_sg" {
  source      = "../../modules/security_group"
  name        = "jenkins-sg"
  description = "Security group for Jenkins EC2"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = [
    {
      description = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "Jenkins UI"
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  egress_rules = [
    {
      description = "All outbound"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

module "eks_cluster_role" {
    source = "../../modules/iam_role"
    
    name        = "eks-cluster-role"
    description = "IAM role for EKS cluster control plane"
    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [{
        Effect = "Allow",
        Principal = { Service = "eks.amazonaws.com" },
        Action   = ["eks:*", "ec2:Describe*", "logs:*"],
        }]
    })
}

resource "aws_iam_role" "eks_node_role" {
  name = "eks-node-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_node_policies" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ])
  role       = aws_iam_role.eks_node_role.name
  policy_arn = each.value
}

module "eks" {
  source              = "../../modules/eks"
  cluster_name        = var.cluster_name
  subnet_ids          = module.vpc.private_subnet_ids
  cluster_role_arn    = module.eks_cluster_role.role_arn
  node_role_arn       = aws_iam_role.eks_node_role.arn
  oidc_provider_url   = var.oidc_provider_url
  oidc_provider_arn   = var.oidc_provider_arn
}

module "rds_sg" {
  source      = "../../modules/security_group"
  name        = "rds-sg"
  description = "Security group for RDS"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = [
    {
      description = "PostgreSQL"
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
    }
  ]
}

module "rds" {
  source              = "../../modules/rds"
  name_prefix         = var.env
  subnet_ids          = module.vpc.private_subnet_ids
  security_group_ids  = [module.rds_sg.security_group_id]
  db_name             = var.db_name
  username            = var.db_username
  password            = var.db_password
}

module "jenkins_ec2" {
  source            = "../../modules/ec2"
  instance_type     = var.jenkins_instance_type
  key_name          = var.key_name
  security_group_id = module.jenkins_sg.security_group_id
  subnet_id         = module.vpc.public_subnet_ids[0]
  ami_id            = "ami-0c55b159cbfafe1f0" 
}
