#!/bin/bash

# Install dependencies
apt update && apt install -y python3-pip git unzip

# Clone your project (replace with your repo)
cd /home/ubuntu
git clone https://github.com/Chinzzii/ai-research-assistant.git
cd ai-research-assistant

# Make sure pip3 is the latest version
python3 -m pip install --upgrade pip

# Install requirements
pip3 install -r requirements.txt

# Add pip binaries to PATH (optional backup)
echo 'export PATH=$PATH:/home/ubuntu/.local/bin' >> /home/ubuntu/.bashrc
export PATH=$PATH:/home/ubuntu/.local/bin

# Export OpenAI key for use
echo "OPENAI_API_KEY=${openai_api_key}" >> /etc/environment

# Run backend (private)
nohup uvicorn backend.app:app --host 0.0.0.0 --port 8000 > backend.log 2>&1 &

# Run frontend (public)
nohup python3 -m streamlit run frontend/app.py --server.port 8501 --server.address 0.0.0.0 > streamlit.log 2>&1 &
