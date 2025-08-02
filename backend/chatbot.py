from openai import OpenAI
import os

client = OpenAI()
openai_api_key = os.getenv("OPENAI_API_KEY")

def ask_question(question, context="", chat_history=[]):
    prompt = f"Answer the following question based on the academic paper content below as well as the chat history:\n\nQuestion:\n{question}\n\nContext:\n{context}\n\nChat History:\n{chat_history}"

    response = client.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=[
            {"role": "system", "content": "You are a helpful research assistant."},
            {"role": "user", "content": prompt}
        ]
    )

    return response.choices[0].message.content
