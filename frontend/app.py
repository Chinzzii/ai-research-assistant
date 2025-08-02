import streamlit as st
import requests

st.title("📄 AI Research Assistant")

# Initialize session state for summary and chat history
if "summary" not in st.session_state:
    st.session_state.summary = None
if "chat_history" not in st.session_state:
    st.session_state.chat_history = []

st.sidebar.header("Upload PDF")
uploaded_file = st.sidebar.file_uploader("Choose a PDF file", type="pdf")
title = st.sidebar.text_input("Paper Title", "example")

# Summarize only once
if uploaded_file and title and st.session_state.summary is None:
    with st.spinner("Summarizing..."):
        files = {"file": uploaded_file.getvalue()}
        data = {"title": title}
        response = requests.post("http://localhost:8000/summarize", files=files, data=data)

        try:
            summary = response.json().get("summary")
            if summary:
                st.session_state.summary = summary
            else:
                st.error("No summary received from backend.")
        except Exception as e:
            st.error(f"Failed to parse JSON: {e}")

# Display summary
if st.session_state.summary:
    st.subheader("🔍 Summary")
    st.write(st.session_state.summary)

    st.subheader("💬 Chat with the Paper")
    question = st.text_input("Ask a question about this paper:")
    if st.button("Ask") and question:
        chat_payload = {
            "question": question,
            "context": st.session_state.summary
        }
        chat_response = requests.post("http://localhost:8000/chat", json=chat_payload)
        answer = chat_response.json().get("response")
        st.session_state.chat_history.append(("You", question))
        st.session_state.chat_history.append(("Assistant", answer))

    # Show chat history
    for sender, msg in st.session_state.chat_history:
        st.markdown(f"**{sender}:** {msg}")

    st.subheader("📚 Similar Papers")
    recommend_response = requests.get("http://localhost:8000/recommend", params={"title": title})
    for rec in recommend_response.json().get("recommendations", []):
        st.markdown(f"**{rec['title']}**: {rec['summary']}")
