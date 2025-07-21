variable "aws_region" {}
variable "vpc_cidr" {}
variable "public_subnets" { type = list(string) }
variable "private_subnets" { type = list(string) }
variable "env" {}
variable "cluster_name" {}
variable "db_name" {}
variable "db_username" {}
variable "db_password" {}
variable "key_name" {}
variable "jenkins_instance_type" {}
variable "oidc_provider_arn" {}
variable "oidc_provider_url" {}