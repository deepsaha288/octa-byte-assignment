resource "aws_iam_role" "this" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = var.assume_role_services
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = var.role_name
  }
}

resource "aws_iam_policy" "this" {
  count = var.create_policy ? 1 : 0

  name        = "${var.role_name}-policy"
  description = var.policy_description
  policy      = var.policy_json
}

resource "aws_iam_role_policy_attachment" "this" {
  count      = var.create_policy ? 1 : 0
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this[0].arn
}
resource "eks_cluster_role" "this" {
  cluster_name = var.cluster_name
  role_arn     = aws_iam_role.this.arn

  depends_on = [aws_iam_role_policy_attachment.this]
  
}
resource "aws_iam_role" "alb_ingress_controller" {
  name = "eks-alb-ingress-controller-role"

  assume_role_policy = data.aws_iam_policy_document.alb_ingress_assume_role_policy.json
}

data "aws_iam_policy_document" "alb_ingress_assume_role_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_provider_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "alb_ingress_controller" {
  role       = aws_iam_role.alb_ingress_controller.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLoadBalancerControllerIAMPolicy"
}

variable "oidc_provider_arn" {
  description = "The ARN of the OIDC provider for the EKS cluster"
  type        = string
}

variable "oidc_provider_url" {
  description = "The URL of the OIDC provider for the EKS cluster"
  type        = string
}
