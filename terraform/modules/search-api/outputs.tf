output redis_host {
    description = "hostname of redis cluster"
    value = module.elasticache-redis.host
}

output ecr_repo_url {
    description = "url of ecr repo"
    value = module.ecr.repository_url
}