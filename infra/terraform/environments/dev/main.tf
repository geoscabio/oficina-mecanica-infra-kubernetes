module "eks" {
  source = "../../modules/eks"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  eks_cluster_role_name = var.eks_cluster_role_name
  eks_node_role_name    = var.eks_node_role_name

  vpc_id             = local.vpc_id
  private_subnet_ids = local.private_subnet_ids

  # AWS Academy: restrict this to the authorized public IP when possible.
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs

  node_group_name = var.node_group_name
  instance_types  = var.instance_types

  desired_size = var.desired_size
  min_size     = var.min_size
  max_size     = var.max_size

  tags = local.common_tags
}

module "ecr" {
  source = "../../modules/ecr"

  name = var.api_ecr_repository_name

  tags = local.common_tags
}