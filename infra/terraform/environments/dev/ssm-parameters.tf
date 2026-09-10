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