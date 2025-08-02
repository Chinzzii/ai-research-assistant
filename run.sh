#!/bin/bash

source venv/Scripts/activate

# Start backend
echo "Starting FastAPI backend..."
uvicorn backend.app:app --port 8000 &

# Start frontend
echo "Launching Streamlit frontend..."
streamlit run frontend/app.py