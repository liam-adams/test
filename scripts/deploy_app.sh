#!/usr/bin/env bash

region='us-east-1'
account_id='562646969323'
repo_name='assessment'

function build_and_push_ecr() {
    cd ..
    aws ecr get-login-password --region $region | docker login --username AWS --password-stdin "$account_id.dkr.ecr.$region.amazonaws.com"
    docker build -t searchapi:0.1.0 .
    docker tag searchapi:latest $account_id.dkr.ecr.$region.amazonaws.com/$repo_name
    docker push $account_id.dkr.ecr.$region.amazonaws.com/$repo_name
    # docker run --rm -p 8000:8000 assessment/searchapi:0.1.0
}

function build_and_push() {
    cd ..
    docker build -t searchapi:0.1.0 .
    docker tag searchapi:0.1.0 lbadams2/assessment:0.1.0
    docker push lbadams2/assessment:0.1.0
    # docker run --rm -p 8000:8000 assessment/searchapi:0.1.0
}

function install_helm_chart_ecr() {
    cd ../helm
    helm install search-api --version 0.1.0 oci://$account_id.dkr.ecr.$region.amazonaws.com
}

function install_helm_chart() {
    cd ../helm
    helm install search-api ./search-api-0.1.0.tgz
}

function build_py_package() {
    python setup.py install
}

export AWS_ACCESS_KEY_ID=$1
export AWS_SECRET_ACCESS_KEY=$2

build_and_push