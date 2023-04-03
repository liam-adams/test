output redis_host {
    description = "hostname of redis cluster"
    value = module.elasticache-redis.host
}