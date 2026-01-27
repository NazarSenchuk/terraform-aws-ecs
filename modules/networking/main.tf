module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.general.project}-${var.general.environment}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.general.region}a", "${var.general.region}b", "${var.general.region}c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]


  single_nat_gateway = true
  enable_nat_gateway = true
  one_nat_gateway_per_az = false
  enable_vpn_gateway = false
  tags = var.general.tags
}