data "aws_ssm_parameter" "vpc_status" {
  name = var.vpc_status_parameter_name
}

data "aws_ssm_parameter" "vpc_id" {
  name = "${var.vpc_ssm_prefix}/vpc_id"
}

data "aws_ssm_parameter" "private_subnet_ids" {
  name = "${var.vpc_ssm_prefix}/private_subnet_ids"
}