resource "aws_ssm_parameter" "cluster_name" {
  name        = "${var.kubernetes_ssm_prefix}/cluster_name"
  description = "EKS cluster name used by the Oficina Mecanica API."
  type        = "String"
  value       = module.eks.cluster_name

  tags = local.common_tags
}

resource "aws_ssm_parameter" "cluster_endpoint" {
  name        = "${var.kubernetes_ssm_prefix}/cluster_endpoint"
  description = "EKS cluster endpoint used by dependent pipelines."
  type        = "String"
  value       = module.eks.cluster_endpoint

  tags = local.common_tags
}

resource "aws_ssm_parameter" "cluster_security_group_id" {
  name        = "${var.kubernetes_ssm_prefix}/cluster_security_group_id"
  description = "EKS cluster security group ID used by dependent resources."
  type        = "String"
  value       = module.eks.cluster_security_group_id

  tags = local.common_tags
}

resource "aws_ssm_parameter" "node_group_name" {
  name        = "${var.kubernetes_ssm_prefix}/node_group_name"
  description = "EKS managed node group name."
  type        = "String"
  value       = module.eks.node_group_name

  tags = local.common_tags
}

resource "aws_ssm_parameter" "ecr_repository_name" {
  name        = "${var.kubernetes_ssm_prefix}/ecr_repository_name"
  description = "ECR repository name used by the API image."
  type        = "String"
  value       = module.ecr.repository_name

  tags = local.common_tags
}

resource "aws_ssm_parameter" "ecr_repository_url" {
  name        = "${var.kubernetes_ssm_prefix}/ecr_repository_url"
  description = "ECR repository URL used by the API image."
  type        = "String"
  value       = module.ecr.repository_url

  tags = local.common_tags
}

resource "aws_ssm_parameter" "status" {
  # Publicar ready somente após concluir a infraestrutura e seus contratos SSM.
  depends_on = [
    module.eks,
    module.ecr,
    aws_ssm_parameter.cluster_name,
    aws_ssm_parameter.cluster_endpoint,
    aws_ssm_parameter.cluster_security_group_id,
    aws_ssm_parameter.node_group_name,
    aws_ssm_parameter.ecr_repository_name,
    aws_ssm_parameter.ecr_repository_url,
  ]

  name        = var.kubernetes_status_parameter_name
  description = "Operational status of the shared Kubernetes infrastructure."
  type        = "String"
  value       = "ready"

  tags = local.common_tags
}

resource "aws_ssm_parameter" "api_internal_node_port" {
  name        = "${var.kubernetes_ssm_prefix}/api_internal_node_port"
  description = "Contractual NodePort used by the API private ingress."
  type        = "String"
  value       = tostring(var.api_internal_node_port)

  tags = local.common_tags
}

resource "aws_ssm_parameter" "internal_nlb_arn" {
  name        = "${var.kubernetes_ssm_prefix}/internal_nlb_arn"
  description = "ARN of the internal NLB used by the API private ingress."
  type        = "String"
  value       = aws_lb.api_internal.arn

  tags = local.common_tags
}

resource "aws_ssm_parameter" "internal_nlb_dns_name" {
  name        = "${var.kubernetes_ssm_prefix}/internal_nlb_dns_name"
  description = "DNS name of the internal NLB used by the API private ingress."
  type        = "String"
  value       = aws_lb.api_internal.dns_name

  tags = local.common_tags
}

resource "aws_ssm_parameter" "internal_nlb_security_group_id" {
  name        = "${var.kubernetes_ssm_prefix}/internal_nlb_security_group_id"
  description = "Security group ID attached to the internal API NLB."
  type        = "String"
  value       = aws_security_group.api_internal_nlb.id

  tags = local.common_tags
}

resource "aws_ssm_parameter" "internal_nlb_target_group_arn" {
  name        = "${var.kubernetes_ssm_prefix}/internal_nlb_target_group_arn"
  description = "ARN of the target group used by the API private ingress."
  type        = "String"
  value       = aws_lb_target_group.api_internal.arn

  tags = local.common_tags
}

resource "aws_ssm_parameter" "internal_nlb_listener_arn" {
  name        = "${var.kubernetes_ssm_prefix}/internal_nlb_listener_arn"
  description = "ARN of the listener consumed by the future API Gateway VPC Link."
  type        = "String"
  value       = aws_lb_listener.api_internal.arn

  tags = local.common_tags
}
