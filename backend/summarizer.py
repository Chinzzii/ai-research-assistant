import fitz  # PyMuPDF
from openai import OpenAI
from dotenv import load_dotenv
import os

load_dotenv()
client = OpenAI()
openai_api_key = os.getenv("OPENAI_API_KEY")

async def summarize_pdf(file):
    pdf_bytes = await file.read()
    doc = fitz.open(stream=pdf_bytes, filetype="pdf")
    text = "\n".join([page.get_text() for page in doc])

    # Optionally chunk the text here for long docs
    prompt = f"Summarize the following academic paper:\n\n{text[:3000]}"

    response = client.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=[
            {"role": "system", "content": "You are an expert research assistant."},
            {"role": "user", "content": prompt}
        ]
    )   

    return response.choices[0].message.content
