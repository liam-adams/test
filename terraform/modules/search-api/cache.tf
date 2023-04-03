/*
module "elasticache-redis" {
  source  = "cloudposse/elasticache-redis/aws"
  version = "0.50.0"

  availability_zones         = data.aws_availability_zones.available.names
  vpc_id                     = module.vpc.vpc_id
  allowed_security_group_ids = [aws_security_group.redis.id]
  subnets                    = module.vpc.private_subnets
  cluster_size               = var.redis_cluster_size
  instance_type              = var.redis_instance_type
  apply_immediately          = true
  automatic_failover_enabled = false
  create_security_group      = false
  engine_version             = var.redis_engine_version
  family                     = var.redis_family
  transit_encryption_enabled = true
  description                = "none"
  replication_group_id       = "none"
}
*/