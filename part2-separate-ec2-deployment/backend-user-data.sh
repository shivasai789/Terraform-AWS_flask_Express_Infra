#!/bin/bash

# Update and install dependencies
apt-get update -y
apt-get install -y python3 python3-pip python3-venv git

# Clone repository FIRST
mkdir -p /opt
git clone https://github.com/shivasai789/flask-backend.git /opt/flask-backend

# Then create virtual environment inside the cloned repo
cd /opt/flask-backend
python3 -m venv venv
source venv/bin/activate

# Install requirements
pip install -r requirements.txt

# Create systemd service (using venv python)
cat > /etc/systemd/system/flask.service <<EOL
[Unit]
Description=Flask Backend Service
After=network.target

[Service]
User=root
WorkingDirectory=/opt/flask-backend
Environment="PATH=/opt/flask-backend/venv/bin:/usr/bin"
ExecStart=/opt/flask-backend/venv/bin/python app.py
Restart=always

[Install]
WantedBy=multi-user.target
EOL

# Enable and start service
systemctl daemon-reload
systemctl enable flask
systemctl start flask