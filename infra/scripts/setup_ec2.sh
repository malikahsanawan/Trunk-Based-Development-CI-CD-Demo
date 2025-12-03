#!/usr/bin/env bash
set -euo pipefail

# Usage: ./infra/scripts/setup_ec2.sh <app_user> <app_dir>
# Example: ./infra/scripts/setup_ec2.sh ubuntu /opt/trunk-demo

APP_USER="${1:-ubuntu}"
APP_DIR="${2:-/opt/trunk-demo}"
PYTHON_VERSION="3.11"

echo "[*] Updating apt cache"
sudo apt-get update

echo "[*] Installing system dependencies"
sudo apt-get install -y python${PYTHON_VERSION} python${PYTHON_VERSION}-venv python${PYTHON_VERSION}-dev build-essential git

echo "[*] Creating application directory at ${APP_DIR}"
sudo mkdir -p "${APP_DIR}"
sudo chown "${APP_USER}:${APP_USER}" "${APP_DIR}"

cd "${APP_DIR}"

echo "[*] Creating virtual environment"
python${PYTHON_VERSION} -m venv .venv
source .venv/bin/activate

echo "[*] Installing Python requirements"
pip install --upgrade pip
pip install -r requirements.txt

echo "[*] Creating systemd service"
SERVICE_PATH="/etc/systemd/system/trunk-demo.service"
sudo tee "${SERVICE_PATH}" > /dev/null <<EOF
[Unit]
Description=Trunk Based Demo FastAPI Service
After=network.target

[Service]
User=${APP_USER}
WorkingDirectory=${APP_DIR}
Environment="PATH=${APP_DIR}/.venv/bin"
ExecStart=${APP_DIR}/.venv/bin/uvicorn app.main:app --host 0.0.0.0 --port 8000
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

echo "[*] Reloading systemd"
sudo systemctl daemon-reload
sudo systemctl enable trunk-demo.service
sudo systemctl restart trunk-demo.service

echo "[*] Deployment complete. Service listening on port 8000."

