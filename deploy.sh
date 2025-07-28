#!/bin/bash

set -e

# === CONFIGURATION ===

KEY_PATH="$HOME/Downloads/sols-keypair.pem"
GIT_REPO="https://github.com/tracy100001/ticket-generator-template.git"
BRANCH="main"

# Define array of targets: "host user remote_dir sub_dir env_file"
TARGETS=(
  "ec2-18-224-138-193.us-east-2.compute.amazonaws.com ubuntu /home/ubuntu/ticketgenerator app .env.production"
)

# === FUNCTIONS ===

run_stage() {
  local HOST="$1"
  local USER="$2"
  local REMOTE_DIR="$3"
  local SUB_DIR="$4"
  local ENV_FILE="$5"

  echo "🔧 Running full deploy pipeline for $HOST..."

  echo ""
  echo "➡️ [1/2] Provision and Clone Repo..."
  ssh -i $KEY_PATH $USER@$HOST << EOF
    set -e
    sudo apt update

    if ! command -v docker &> /dev/null; then
      echo "Installing Docker..."
      curl -fsSL https://get.docker.com -o get-docker.sh
      sh get-docker.sh
      sudo usermod -aG docker $USER
    fi

    if ! command -v docker-compose &> /dev/null; then
      echo "Installing Docker Compose..."
      sudo curl -L "https://github.com/docker/compose/releases/download/v2.38.2/docker-compose-\$(uname -s)-\$(uname -m)" -o /usr/local/bin/docker-compose
      sudo chmod +x /usr/local/bin/docker-compose
    fi

    if ! command -v git &> /dev/null; then
      echo "Installing Git..."
      sudo apt install -y git unzip curl
    fi

    # Prepare project dir
    rm -rf $REMOTE_DIR
    mkdir -p $REMOTE_DIR
    cd $REMOTE_DIR

    git clone -b $BRANCH $GIT_REPO .
EOF

  # echo ""
  # echo "➡️ [2/3] Sync .env File..."
  # echo "Uploading: $SUB_DIR/$ENV_FILE --> $REMOTE_DIR/$SUB_DIR/.env"

  # scp -i "$KEY_PATH" "$SUB_DIR/$ENV_FILE" "$USER@$HOST:$REMOTE_DIR/$SUB_DIR/.env"

  echo ""
  echo "➡️ [2/2] Deploy via Docker Compose..."
  ssh -i $KEY_PATH $USER@$HOST << EOF
    set -e
    cd $REMOTE_DIR/$SUB_DIR
    rm -rf .next

    docker compose down --remove-orphans

    docker compose pull || true
    docker compose up -d --build
EOF

  echo "✅ $SUB_DIR deployed to $HOST successfully."
  echo "--------------------------------------------"
  echo ""
}

# === EXECUTION LOGIC ===

INDEX=${1:-0}

if (( INDEX < 0 || INDEX >= ${#TARGETS[@]} )); then
  echo "❌ Invalid index: $INDEX"
  exit 1
fi

# Parse selected target
IFS=' ' read -r HOST USER REMOTE_DIR SUB_DIR ENV_FILE <<< "${TARGETS[$INDEX]}"

run_stage "$HOST" "$USER" "$REMOTE_DIR" "$SUB_DIR" "$ENV_FILE"

echo "🎉 ALL DONE — Project [$SUB_DIR] deployed to [$HOST]"
