import fastapi
from fastapi import FastAPI
import os
import asyncio
from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
from google.cloud import firestore
from google.oauth2 import service_account
import json
import numpy as np
from tensorflow import keras
# from sklearn.preprocessing import LabelEncoder
import random
import pickle


service_account_key_path = "D:\chatbot\Backend_model\chatbot-294f4-firebase-adminsdk-af7lw-74f7fd62e5.json"


credentials = service_account.Credentials.from_service_account_file(
    service_account_key_path)
db = firestore.Client(credentials=credentials)


app = FastAPI(debug=True)

# origins = [
#     "http://localhost.tiangolo.com",
#     "https://localhost.tiangolo.com",
#     "http://localhost",
#     "http://localhost:4001",
#     "http://localhost:4000",
#     "http://localhost:59981",
# ]
origins = ["*"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

with open("D:\chatbot\Backend_model\website.json") as file:
    data = json.load(file)
model = keras.models.load_model('D:\chatbot\Backend_model\chat_model.h5')
with open('D:/chatbot/backend_model/tokenizer.pickle', 'rb') as handle:
    tokenizer = pickle.load(handle)
with open('D:\chatbot\Backend_model\label_encoder.pickle', 'rb') as enc:
    lbl_encoder = pickle.load(enc)
max_len = 20


@app.get("/get/{input}")
async def response(input: str):
    result = model.predict(keras.preprocessing.sequence.pad_sequences(tokenizer.texts_to_sequences([input]),
                                                                      truncating='post', maxlen=max_len))
    tag = lbl_encoder.inverse_transform([np.argmax(result)])
    for i in data['intents']:
        if i['tag'] == tag:
            return np.random.choice(i['responses'])


@app.put("/add/{question}/{answer}/{conid}")
async def create_request(question: str, answer: str, conid: str):
    data = {'question': question, 'answer': answer, 'conversation_id': conid}
    doc_ref = db.collection('data').document()
    doc_ref.set(data)
    return doc_ref.id


@app.put("/addconversation/")
async def create_conversation():
    data = {'rating': '0'}
    doc_ref = db.collection('conversation').document()
    doc_ref.set(data)
    return doc_ref.id


@app.post("/update/{id}/{rating}")
async def update_request(id: str, rating: str):
    data = {'rating': rating}
    doc_ref = db.collection('conversation').document(id)
    doc_ref.update(data)


@app.get("/getall/{id}")
async def get_all_data(id: str):
    request_ref = db.collection("data")
    query_ref = request_ref.where("conversation_id", "==", id)
    requests = [doc.to_dict() for doc in query_ref.stream()]
    return JSONResponse(content=requests)


@app.get("/getrating/{id}")
async def get_rating(id: str):
    request_ref = db.collection("conversation").document(id)
    request = request_ref.get()
    if request.exists:
        return JSONResponse(content=request.to_dict())
    else:
        return JSONResponse(content={"message": "Document does not exist"})


@app.get("/loadconversations")
def get_document_ids():
    request_ref = db.collection("conversation")
    document_ids = [doc.id for doc in request_ref.stream()]
    return JSONResponse(content=document_ids)


@app.get("/loadfilterconversations/{rating}")
def get_filter_document_ids(rating: str):
    if (rating == "0"):
        request_ref = db.collection("conversation")
        document_ids = [doc.id for doc in request_ref.stream()]
        return JSONResponse(content=document_ids)
    else:
        request_ref = db.collection("conversation")
        query_ref = request_ref.where("rating", "==", rating)
        document_ids = [doc.id for doc in query_ref.stream()]
        return JSONResponse(content=document_ids)


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
