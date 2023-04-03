variable vpc_cidr {
    description = "cidr for vpc"
    type = string
}

variable private_subnet_cidrs {
    description = "private cidrs for vpc"
    type = list(string)
}

variable public_subnet_cidrs {
    description = "public cidrs for vpc"
    type = list(string)
}

variable instance_type {
    description = "instance type for EKS nodes"
    type = string
}

variable eks_version {
    description = "version of kubernetes"
    type = string
}

variable name {
    description = "name of application"
    type = string
}

variable desired_capacity {
    description = "desired number of nodes in EKS"
    type = number
}

variable min_capacity {
    description = "minimum number of nodes in EKS"
    type = number
}

variable max_capacity {
    description = "maximum number of nodes in EKS"
    type = number
}

/*
variable redis_cluster_size {
    description = "size of redis cluster"
    type = number
}

variable redis_instance_type {
    description = "type of nodes in redis cluster"
    type = string
}

variable redis_engine_version {
    description = "version of redis"
    type = string
}

variable redis_family {
    description = "for parameter group applied to cluster"
    type = string
}

variable ecr_repo {
    description = "ecr repo name"
    type = string
}
*/