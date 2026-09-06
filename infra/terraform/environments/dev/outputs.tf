output "eks_cluster_name" {
  description = "EKS cluster name."
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint."
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_security_group_id" {
  description = "EKS cluster security group ID."
  value       = module.eks.cluster_security_group_id
}

output "eks_node_group_name" {
  description = "EKS managed node group name."
  value       = module.eks.node_group_name
}

output "ecr_repository_name" {
  description = "ECR repository name used by the API image."
  value       = module.ecr.repository_name
}

output "ecr_repository_url" {
  description = "ECR repository URL used by the API image."
  value       = module.ecr.repository_url
}

output "ssm_kubernetes_prefix" {
  description = "SSM prefix published by this pipeline."
  value       = var.kubernetes_ssm_prefix
}

output "ssm_kubernetes_status_parameter_name" {
  description = "SSM parameter that marks Kubernetes as ready."
  value       = var.kubernetes_status_parameter_name
}