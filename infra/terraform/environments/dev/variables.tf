variable "aws_region" {
  description = "AWS region where the Kubernetes infrastructure will be provisioned."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Provisioned environment name."
  type        = string
  default     = "development"
}

variable "eks_cluster_role_name" {
  description = "Existing IAM role used by the EKS cluster in AWS Academy."
  type        = string
}

variable "eks_node_role_name" {
  description = "Existing IAM role used by the EKS managed node group in AWS Academy."
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name."
  type        = string
  default     = "oficina-mecanica-eks-dev"
}

variable "cluster_version" {
  description = "Kubernetes version used by EKS."
  type        = string
  default     = "1.33"
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "CIDR blocks allowed to access the public EKS endpoint."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "node_group_name" {
  description = "EKS managed node group name."
  type        = string
  default     = "oficina-mecanica-node-group-dev"
}

variable "instance_types" {
  description = "EC2 instance types used by the EKS managed node group."
  type        = list(string)
  default     = ["t3.small"]
}

variable "desired_size" {
  description = "Desired amount of worker nodes."
  type        = number
  default     = 1
}

variable "min_size" {
  description = "Minimum amount of worker nodes."
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum amount of worker nodes."
  type        = number
  default     = 1
}

variable "api_ecr_repository_name" {
  description = "ECR repository name used by the API image."
  type        = string
  default     = "oficina-mecanica-api"
}

variable "vpc_ssm_prefix" {
  description = "SSM prefix published by the VPC pipeline."
  type        = string
  default     = "/oficina-mecanica/development/vpc"
}

variable "vpc_status_parameter_name" {
  description = "SSM parameter that marks the VPC as ready."
  type        = string
  default     = "/oficina-mecanica/development/status/vpc"
}

variable "kubernetes_ssm_prefix" {
  description = "SSM prefix published by this Kubernetes pipeline."
  type        = string
  default     = "/oficina-mecanica/development/kubernetes"
}

variable "kubernetes_status_parameter_name" {
  description = "SSM parameter that marks Kubernetes as ready."
  type        = string
  default     = "/oficina-mecanica/development/status/kubernetes"
}