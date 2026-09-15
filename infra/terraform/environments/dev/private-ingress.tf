locals {
  api_node_group_asg_name = module.eks.node_group_autoscaling_group_name

  api_private_ingress_tags = merge(local.common_tags, {
    Component = "ApiPrivateIngress"
  })
}

resource "aws_security_group" "api_internal_nlb" {
  name        = "oficina-mecanica-api-nlb-sg-dev"
  description = "Security group for the internal API Network Load Balancer."
  vpc_id      = local.vpc_id

  tags = merge(local.api_private_ingress_tags, {
    Name         = "oficina-mecanica-api-nlb-sg-dev"
    ResourceType = "SecurityGroup"
  })
}

# The future API Gateway VPC Link will add the only ingress rule to this SG.
resource "aws_vpc_security_group_egress_rule" "api_internal_nlb_to_nodes" {
  security_group_id            = aws_security_group.api_internal_nlb.id
  referenced_security_group_id = module.eks.cluster_security_group_id
  ip_protocol                  = "tcp"
  from_port                    = var.api_internal_node_port
  to_port                      = var.api_internal_node_port
  description                  = "Allow the internal NLB to reach the API NodePort on EKS nodes."
}

resource "aws_vpc_security_group_ingress_rule" "nodes_from_api_internal_nlb" {
  security_group_id            = module.eks.cluster_security_group_id
  referenced_security_group_id = aws_security_group.api_internal_nlb.id
  ip_protocol                  = "tcp"
  from_port                    = var.api_internal_node_port
  to_port                      = var.api_internal_node_port
  description                  = "Allow the internal API NLB to reach the contractual API NodePort."
}

resource "aws_lb" "api_internal" {
  name                             = "oficina-mecanica-api-nlb-dev"
  internal                         = true
  load_balancer_type               = "network"
  subnets                          = local.private_subnet_ids
  security_groups                  = [aws_security_group.api_internal_nlb.id]
  enable_cross_zone_load_balancing = true

  # The NLB spans two private subnets while the lab currently has one worker node.
  # Cross-zone balancing keeps both NLB AZ nodes able to reach that single healthy target.
  tags = merge(local.api_private_ingress_tags, {
    Name         = "oficina-mecanica-api-nlb-dev"
    ResourceType = "NLB"
  })
}

resource "aws_lb_target_group" "api_internal" {
  name        = "oficina-mecanica-api-tg-dev"
  port        = var.api_internal_node_port
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = local.vpc_id

  health_check {
    protocol = "TCP"
  }

  tags = merge(local.api_private_ingress_tags, {
    Name         = "oficina-mecanica-api-tg-dev"
    ResourceType = "TargetGroup"
  })
}

resource "aws_autoscaling_attachment" "api_internal" {
  autoscaling_group_name = local.api_node_group_asg_name
  lb_target_group_arn    = aws_lb_target_group.api_internal.arn
}

resource "aws_lb_listener" "api_internal" {
  load_balancer_arn = aws_lb.api_internal.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api_internal.arn
  }
}
