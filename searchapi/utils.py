from onnx_model import SklearnOnnx
import boto3
import redis
import os

redis_client = redis.Redis(host=os.environ['REDIS_HOST'], port=6379, db=0)
s3_client = boto3.client('s3')

# https://stackoverflow.com/questions/64274200/azure-kubernetes-python-to-read-configmap
def get_model(path=None):
    if not path:
        bucket = os.environ['BUCKET']
        key = os.environ['MODEL_KEY']        
        s3_client.download_file(bucket, key, path)
    model = SklearnOnnx(path)
    return model

def cache_query(query, response):
    redis_client.json().set(query, response)

def get_cache_query(query):
    return redis_client.json().get(query)