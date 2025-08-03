#!/bin/bash

set -e

# Update and install required system packages
sudo apt update && sudo apt install -y python3-pip python3-venv git unzip

# Set working directory
cd /home/ubuntu

# Clone the repo
git clone https://github.com/Chinzzii/ai-research-assistant.git
cd ai-research-assistant

# Create virtual environment
python3 -m venv venv

# Activate venv
source venv/bin/activate

# Upgrade pip
pip install --upgrade pip

# Fix faiss + numpy compatibility
pip uninstall -y numpy
pip install "numpy<2.0"

# Install Python dependencies
pip install -r requirements.txt

# Add pip binaries to PATH for future sessions
echo 'export PATH=$PATH:/home/ubuntu/ai-research-assistant/venv/bin' >> /home/ubuntu/.bashrc

# Export OpenAI key for backend (optional, also picked by dotenv)
echo "OPENAI_API_KEY=${openai_api_key}" | sudo tee -a /etc/environment
export OPENAI_API_KEY=${openai_api_key}

# Run backend
nohup venv/bin/uvicorn backend.app:app --host 0.0.0.0 --port 8000 > backend.log 2>&1 &

# Run frontend
nohup venv/bin/python -m streamlit run frontend/app.py --server.port 8501 --server.address 0.0.0.0 > streamlit.log 2>&1 &
