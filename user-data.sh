#!/bin/bash
# EC2 bootstrap script — makes the box look like a real corporate app server.
apt-get update -y
apt-get install -y nginx
cat > /var/www/html/index.html <<'EOF'
<html><head><title>Internal Portal</title></head>
<body><h1>CorpApp Internal Server</h1><p>Status: OK</p></body></html>
EOF
systemctl enable nginx
systemctl start nginx
