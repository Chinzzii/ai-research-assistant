#!/bin/bash

# Exit on error
set -e

# Update and install system packages
sudo apt update && sudo apt install -y python3-pip git unzip

# Clone your project repo
cd /home/ubuntu
if [ ! -d "ai-research-assistant" ]; then
  git clone https://github.com/Chinzzii/ai-research-assistant.git
fi
cd ai-research-assistant

# Upgrade pip
python3 -m pip install --upgrade pip

# Install Python requirements (system-wide)
sudo pip3 install -r requirements.txt

# Add pip binaries to PATH and source bashrc
echo 'export PATH=$PATH:/home/ubuntu/.local/bin' >> /home/ubuntu/.bashrc
export PATH=$PATH:/home/ubuntu/.local/bin

# Export OpenAI API key
echo "OPENAI_API_KEY=${openai_api_key}" | sudo tee -a /etc/environment
export OPENAI_API_KEY=${openai_api_key}

# Run backend with absolute path to uvicorn
UVICORN_BIN=$(which uvicorn || echo "/usr/local/bin/uvicorn")
nohup "$UVICORN_BIN" backend.app:app --host 0.0.0.0 --port 8000 > backend.log 2>&1 &

# Run frontend with absolute path to streamlit
STREAMLIT_BIN=$(which streamlit || echo "/usr/local/bin/streamlit")
nohup python3 -m streamlit run frontend/app.py --server.port 8501 --server.address 0.0.0.0 > streamlit.log 2>&1 &
