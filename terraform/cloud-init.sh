#!/bin/bash

set -e

# Update and install system packages
sudo apt update && sudo apt install -y python3-pip python3-venv git unzip

# Clone your project
cd /home/ubuntu
git clone https://github.com/Chinzzii/ai-research-assistant.git
cd ai-research-assistant

# Create and activate virtual environment
python3 -m venv venv
source venv/bin/activate

# Upgrade pip inside venv
pip install --upgrade pip

# Fix numpy compatibility for faiss
pip3 uninstall -y numpy
pip3 install numpy<2.0

# Install dependencies
pip install -r requirements.txt

# Set OPENAI_API_KEY in system-wide environment
echo "OPENAI_API_KEY=${openai_api_key}" | sudo tee -a /etc/environment
export OPENAI_API_KEY=${openai_api_key}

# Run backend (inside venv)
nohup venv/bin/uvicorn backend.app:app --host 0.0.0.0 --port 8000 > backend.log 2>&1 &

# Run frontend (inside venv)
nohup venv/bin/python -m streamlit run frontend/app.py --server.port 8501 --server.address 0.0.0.0 > streamlit.log 2>&1 &
