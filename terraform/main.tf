module "search_api" {
  source = "./modules/search-api"

  vpc_cidr             = var.vpc_cidr
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs
  instance_type        = var.instance_type
  eks_version          = var.eks_version
  name                 = var.name
  desired_capacity     = var.desired_capacity
  min_capacity         = var.min_capacity
  max_capacity         = var.max_capacity
  public_access_ips    = var.public_access_ips
  #redis_cluster_size   = var.redis_cluster_size
  #redis_instance_type  = var.redis_instance_type
  #redis_engine_version = var.redis_engine_version
  #redis_family         = var.redis_family
  #ecr_repo             = var.ecr_repo
}
