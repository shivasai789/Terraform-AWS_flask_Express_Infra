#!/bin/bash

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Create application directory
sudo mkdir -p /opt/node-frontend
sudo chown -R ubuntu:ubuntu /opt/node-frontend

# Clone repository
sudo -u ubuntu git clone https://github.com/shivasai789/node-frontend.git /opt/node-frontend

# Create environment file with backend URL
cat > /opt/node-frontend/.env <<EOL
BACKEND_URL=${backend_url}
EOL

# Install dependencies and start application
cd /opt/node-frontend
sudo -u ubuntu npm install
sudo -u ubuntu nohup npm start > node.log 2>&1 &