from onnx_model import SklearnOnnx
import boto3
import redis
import os
import logging
import json

redis_client = redis.Redis(host=os.environ['REDIS_HOST'], port=6379, db=0)
s3_client = boto3.client('s3')

# https://stackoverflow.com/questions/64274200/azure-kubernetes-python-to-read-configmap
def get_model(path=None):
    if not path:
        bucket = os.environ['BUCKET']
        key = os.environ['MODEL_KEY']
        s3_client.download_file(bucket, key, key)
    model = SklearnOnnx(key)
    return model

def cache_query(query, response):
    redis_client.set(query, json.dumps(response))

def get_cache_query(query):
    res_str = redis_client.get(query)
    if res_str is None:
        logging.info(f'Cache miss for {query}')
        return None
    else:
        logging.info(f'Cache hit for {query}')
        res = json.loads(res_str)
        return res