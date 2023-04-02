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
    cats, proba = model.predict(query)
    return {"query": query, "cats": cats, "prob": proba}

if __name__ == '__main__':
    uvicorn.run(app, host="0.0.0.0", port=8000, log_level='debug')