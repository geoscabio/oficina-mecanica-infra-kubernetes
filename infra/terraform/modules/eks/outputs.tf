output "cluster_name" {
  description = "Nome do cluster EKS."
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "Endpoint do cluster EKS."
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_security_group_id" {
  description = "ID do security group principal do cluster EKS."
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "node_group_name" {
  description = "Nome do Managed Node Group."
  value       = aws_eks_node_group.this.node_group_name
}