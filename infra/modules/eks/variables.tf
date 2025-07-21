variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "subnet_ids" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "cluster_role_arn" {
  description = "IAM role ARN for EKS control plane"
  type        = string
}

variable "node_role_arn" {
  description = "IAM role ARN for EKS worker nodes"
  type        = string
}

variable "service_ipv4_cidr" {
  description = "CIDR block for Kubernetes services"
  type        = string
  default     = "172.20.0.0/16"
}

variable "desired_capacity" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 3
}

variable "instance_types" {
  description = "List of EC2 instance types for worker nodes"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_disk_size" {
  description = "EBS volume size for each node"
  type        = number
  default     = 20
}
variable "oidc_provider_arn" {
  description = "ARN of the OIDC provider for EKS"
  type        = string
}
variable "oidc_provider_url" {
  description = "URL of the OIDC provider for EKS"
  type        = string
}
