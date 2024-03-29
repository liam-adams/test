# will create an oidc provider by default
# https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html
# https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html
# https://aws.amazon.com/blogs/opensource/network-load-balancer-nginx-ingress-controller-eks/
# https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/modules/irsa/main.tf
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.12.0"

  cluster_name    = var.name
  cluster_version = var.eks_version
  subnet_ids      = module.vpc.private_subnets

  vpc_id = module.vpc.vpc_id

  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = var.public_access_ips

  # creates autoscaling group
  # might be able to use this https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group
  eks_managed_node_groups = {
    first = {
      desired_capacity = var.desired_capacity
      max_capacity     = var.max_capacity
      min_capacity     = var.min_capacity

      instance_type = var.instance_type
    }
  }

  cluster_addons = {}

  # not authorized to create these
  /*
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }
  */

  # due to insufficient permissions
  create_kms_key              = false
  create_cloudwatch_log_group = false
  cluster_encryption_config   = {}
  enable_irsa                 = false
}

# https://geekdudes.wordpress.com/2018/01/10/amazon-autosclaing-using-terraform/
resource "aws_autoscaling_policy" "cpu_policy" {
  count = length(module.eks.eks_managed_node_groups_autoscaling_group_names)
  name                   = "example-cpu-policy${count.index}"
  autoscaling_group_name = module.eks.eks_managed_node_groups_autoscaling_group_names[count.index]
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "1"
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  count = length(module.eks.eks_managed_node_groups_autoscaling_group_names)
  alarm_name          = "example-cpu-alarm${count.index}"
  alarm_description   = "example-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "30"
  dimensions = {
    "AutoScalingGroupName" = "${module.eks.eks_managed_node_groups_autoscaling_group_names[count.index]}"
  }
  actions_enabled = true
  alarm_actions   = ["${aws_autoscaling_policy.cpu_policy[count.index].arn}"]
}

# scale down alarm
resource "aws_autoscaling_policy" "cpu_policy_scaledown" {
  count = length(module.eks.eks_managed_node_groups_autoscaling_group_names)
  name                   = "example-cpu-policy-scaledown${count.index}"
  autoscaling_group_name = module.eks.eks_managed_node_groups_autoscaling_group_names[count.index]
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "-1"
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "cpu_alarm_scaledown" {
  count = length(module.eks.eks_managed_node_groups_autoscaling_group_names)
  alarm_name          = "example-cpu-alarm-scaledown${count.index}"
  alarm_description   = "example-cpu-alarm-scaledown"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "5"
  dimensions = {
    "AutoScalingGroupName" = "${module.eks.eks_managed_node_groups_autoscaling_group_names[count.index]}"
  }
  actions_enabled = true
  alarm_actions   = ["${aws_autoscaling_policy.cpu_policy_scaledown[count.index].arn}"]
}

/*
locals{
  temp_oidc_var = split("/", module.eks.oidc_provider_arn)
  oidc_var = join("", slice(local.temp_oidc_var, 1, length(local.temp_oidc_var)))
}

resource "aws_iam_role" "alb_role" {
  name = "AmazonEKSLoadBalancerControllerRole"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          test = "StringEquals"
          variable = "${local.oidc_var}:aud"
          values = ["sts.amazonaws.com"]
        }
        Condition = {
          test = "StringEquals"
          variable = "${local.oidc_var}:sub"
          values = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
        }
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Federated = module.eks.oidc_provider_arn
        }
      },
    ]
  })
}

resource "aws_iam_policy" "alb_policy" {
  name        = "alb-policy"
  description = "Policy for the ALB"

  policy = file("${path.module}/alb-policy.json")
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.alb_role.name
  policy_arn = aws_iam_policy.alb_policy.arn
}
*/
