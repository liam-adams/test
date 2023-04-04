import uvicorn
from fastapi import FastAPI
#from fastapi.logger import logger
import logging

app = FastAPI()

@app.get("/")
def read_root():
    logging.info('get root')
    return {"Paths": ["/query/$query"]}

if __name__ == '__main__':
    uvicorn.run(app, host="0.0.0.0", port=8000, log_config="logging.yaml")
    logging.info('hello!')