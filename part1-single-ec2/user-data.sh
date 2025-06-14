#!/bin/bash

# Update system and install dependencies
apt-get update -y
apt-get install -y git python3 python3-pip

# Install Node.js (specific version)
curl -fsSL https://deb.nodesource.com/setup_${node_version} | sudo -E bash -
sudo apt-get install -y nodejs

# Setup application directory
mkdir -p /opt/node-frontend
chown -R ubuntu:ubuntu /opt/node-frontend

# Clone and setup frontend (as ubuntu user)
sudo -u ubuntu git clone ${repo_url} /opt/node-frontend
cd /opt/node-frontend
sudo -u ubuntu npm install
sudo -u ubuntu nohup npm start > node.log 2>&1 &

# Setup backend
git clone https://github.com/shivasai789/flask-backend.git /opt/flask-backend
cd /opt/flask-backend
pip3 install -r requirements.txt
nohup python3 app.py > flask.log 2>&1 &

user_data = <<-EOF
              #!/bin/bash
              # Install current Node.js version
              curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
              sudo apt-get install -y nodejs

              # Create application directory with proper permissions
              sudo mkdir -p /opt/node-frontend
              sudo chown -R ubuntu:ubuntu /opt/node-frontend

              # Clone repo (as ubuntu user)
              sudo -u ubuntu git clone https://github.com/shivasai789/node-frontend.git /opt/node-frontend

              # Install dependencies and start app
              cd /opt/node-frontend
              sudo -u ubuntu npm install
              sudo -u ubuntu nohup npm start > node.log 2>&1 &
              EOF