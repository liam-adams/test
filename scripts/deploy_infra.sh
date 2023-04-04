#!/usr/bin/env bash

region='us-east-1'
account_id='562646969323'
repo_name='assessment'

function apply_terraform() { 
    cd ../terraform
    terraform init
    terraform apply
    aws eks update-kubeconfig --region $region --name $repo_name
}


# https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html
# https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html
# https://docs.aws.amazon.com/AmazonECR/latest/userguide/push-oci-artifact.html
function init_helm_ecr() {
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

function init_kube() {
    cd ../helm

    kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
    helm repo update

    kubectl config use-context arn:aws:eks:$region:$account_id:cluster/$repo_name
    helm upgrade -i ingress-nginx ingress-nginx/ingress-nginx \
        --version 4.6.0 \
        --namespace kube-system \
        --values ingress-nginx/values.yaml
    # kubectl get -n kube-system service/ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
    
    kubectl create namespace search-api

    helm repo add bitnami https://charts.bitnami.com/bitnami
    helm install redis bitnami/redis --namespace search-api --values redis/values.yaml
    
    kubectl -n search-api create secret generic aws-creds \
        --from-literal=aws_user=$AWS_ACCESS_KEY_ID \
        --from-literal=aws_secret=$AWS_SECRET_ACCESS_KEY
}

export AWS_ACCESS_KEY_ID=$1
export AWS_SECRET_ACCESS_KEY=$2

apply_terraform
init_kube