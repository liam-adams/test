import uvicorn
from fastapi import FastAPI
import utils

app = FastAPI()
model = utils.get_model()

@app.get("/")
def read_root():
    return {"Paths": ["/query/$query"]}


@app.get("/query/{query}")
def query(query: str):
    result = utils.get_cache_query(query)
    if result is None:
        cats, proba = model.predict(query)
        result = {"query": query, "cats": cats, "prob": proba}
        utils.cache_query(query, result)
    return result

if __name__ == '__main__':
    uvicorn.run(app, host="0.0.0.0", port=8000, log_level='debug')