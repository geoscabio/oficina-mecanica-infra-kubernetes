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

output "api_internal_node_port" {
  description = "Contractual NodePort used by the API private ingress."
  value       = var.api_internal_node_port
}

output "api_internal_nlb_arn" {
  description = "ARN of the internal NLB used by the API private ingress."
  value       = aws_lb.api_internal.arn
}

output "api_internal_nlb_dns_name" {
  description = "DNS name of the internal NLB used by the API private ingress."
  value       = aws_lb.api_internal.dns_name
}

output "api_internal_nlb_security_group_id" {
  description = "Security group ID attached to the internal API NLB."
  value       = aws_security_group.api_internal_nlb.id
}

output "api_internal_target_group_arn" {
  description = "ARN of the target group used by the API private ingress."
  value       = aws_lb_target_group.api_internal.arn
}

output "api_internal_nlb_listener_arn" {
  description = "ARN of the listener consumed by the future API Gateway VPC Link."
  value       = aws_lb_listener.api_internal.arn
}

output "api_node_group_asg_name" {
  description = "Dynamically discovered Auto Scaling group name of the API node group."
  value       = local.api_node_group_asg_name
}
