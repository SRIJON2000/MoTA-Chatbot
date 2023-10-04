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
from transformers import GPT2Tokenizer
from transformers import DistilBertTokenizer, TFDistilBertForQuestionAnswering
import tensorflow as tf


service_account_key_path = "D:\MoTA-Chatbot\Chatbot\Backend_model\chatbot-294f4-firebase-adminsdk-af7lw-74f7fd62e5.json"


credentials = service_account.Credentials.from_service_account_file(
    service_account_key_path)
db = firestore.Client(credentials=credentials)


app = FastAPI(debug=True)

tokenizer = DistilBertTokenizer.from_pretrained(
    "distilbert-base-cased-distilled-squad")
model = TFDistilBertForQuestionAnswering.from_pretrained(
    "distilbert-base-cased-distilled-squad")
file_path = "D:\MoTA-Chatbot\Chatbot\Backend_model\data.txt"
context = "This is a Centrally Sponsored Scheme implemented through States/UTs who are responsible for Inviting applications from students online through State Portal or National Scholarship Portal, check eligibility verification and disbursement of scholarship to eligible ST students directly to their bank accounts through DBT. Funds are released by this Ministry to the State Governments/UTs based on their proposal comprising of Statement of Expenditure, Furnishing of Utilization Certificate and Uploading of beneficiary data on DBT Portal. The main features of the scheme are as under:Applicable to students who are studying in Classes IX – X.Parental income from all sources should not exceed Rs.2.50 lakhs per annum.Scholarships are paid @ Rs.225/- per month for Day Scholars and @ Rs.525/- per month for Hostellers, for a period of 10 months in a year.Funds shared at the ratio of 75:25 between the Centre and State Governments/UT and in ratio of 90:10 for NE and Specially Category States/UTs (UT of Jammu & Kashmir, Himachal Pradesh and Uttarakhand). For UT without legislature 100% grant is given by Centre."
# context = ""
# try:
#     with open(file_path, "r", encoding="utf-8") as file:
#         context = file.read()
# except FileNotFoundError:
#     print("The specified file does not exist.")
# except Exception as e:
#     print(f"An error occurred: {str(e)}")


# model_directory = "D:\MoTA-Chatbot\Chatbot\Backend_model\model.h5"
# tokenizer_directory = "D:\MoTA-Chatbot\Chatbot\Backend_model"

# tokenizer = GPT2Tokenizer.from_pretrained(tokenizer_directory)
# model = keras.models.load_model(model_directory)

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


@app.get("/get/{input}")
async def response(input: str):
    inputs = tokenizer(input, context, return_tensors="tf")
    outputs = model(**inputs)
    answer_start_index = int(tf.math.argmax(outputs.start_logits, axis=-1)[0])
    answer_end_index = int(tf.math.argmax(outputs.end_logits, axis=-1)[0])

    predict_answer_tokens = inputs.input_ids[0,
                                             answer_start_index: answer_end_index + 1]
    return str(tokenizer.decode(predict_answer_tokens))


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
