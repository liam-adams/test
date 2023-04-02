from onnx_model import SklearnOnnx
import boto3
import os

# https://stackoverflow.com/questions/64274200/azure-kubernetes-python-to-read-configmap
def get_model(path=None):
    if not path:
        bucket = os.environ['BUCKET']
        key = os.environ['MODEL_KEY']
        s3_client = boto3.client('s3')
        s3_client.download_file(bucket, key, path)
    model = SklearnOnnx(path)
    return model