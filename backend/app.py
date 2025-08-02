from fastapi import FastAPI, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from backend.summarizer import summarize_pdf
from backend.chatbot import ask_question
from backend.vector_store import store_embedding, get_similar_papers
from backend.utils import extract_title_from_pdf
import logging

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

chat_history = []

@app.post("/summarize")
async def summarize(file: UploadFile = File(...), title: str = Form(...)):
    try:
        summary = await summarize_pdf(file)
        store_embedding(title, summary)
        return {"summary": summary}
    except Exception as e:
        logging.error(f"Error during summarization: {e}")
        return JSONResponse(status_code=500, content={"error": "Summarization failed"})

@app.post("/chat")
async def chat(payload: dict):
    question = payload.get("question")
    context = payload.get("context")
    # Append to history
    chat_history.append({"role": "user", "content": question})
    response = ask_question(question, context, chat_history)
    chat_history.append({"role": "assistant", "content": response})
    return {"response": response, "history": chat_history}

@app.get("/recommend")
async def recommend(title: str):
    papers = get_similar_papers(title)
    return {"recommendations": papers}