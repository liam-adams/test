#!/usr/bin/env bash

region='us-east-1'
account_id='562646969323'
repo_name='assessment'

function apply_terraform() { 
    cd ../terraform
    terraform init
    terraform apply
}


# https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html
# https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html
# https://docs.aws.amazon.com/AmazonECR/latest/userguide/push-oci-artifact.html
function init_helm() {
    cd ../helm
    helm package search-api
    aws ecr get-login-password --region $region \
        | helm registry login --username AWS --password-stdin $account_id.dkr.ecr.$region.amazonaws.com
    helm push search-api-0.1.0.tgz oci://$account_id.dkr.ecr.$region.amazonaws.com/

    helm repo add eks https://aws.github.io/eks-charts
    helm repo update
    helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
        -n kube-system \
        --set clusterName=search-api \
        --set serviceAccount.create=false \
        --set serviceAccount.name=aws-load-balancer-controller
}

export AWS_ACCESS_KEY_ID=$1
export AWS_SECRET_ACCESS_KEY=$2

apply_terraform
init_helm