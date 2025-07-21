variable "role_name" {
  description = "Name of the IAM role"
  type        = string
}

variable "assume_role_services" {
  description = "List of services (e.g., ec2.amazonaws.com, eks.amazonaws.com)"
  type        = list(string)
}

variable "create_policy" {
  description = "Whether to create a custom policy and attach"
  type        = bool
  default     = false
}

variable "policy_description" {
  description = "Description for the IAM policy"
  type        = string
  default     = ""
}

variable "policy_json" {
  description = "IAM policy JSON document"
  type        = string
  default     = ""
}
variable "tags" {
  description = "Tags to apply to the IAM role and policy"
  type        = map(string)
  default     = {}
}
variable "oidc_provider_arn" {
  description = "ARN of the OIDC provider for the EKS cluster"
  type        = string
}

variable "oidc_provider_url" {
  description = "URL of the OIDC provider for the EKS cluster"
  type        = string
}
variable "assume_role_condition" {
  description = "Condition for the assume role policy"
  type        = map(string)
  default     = {}
}