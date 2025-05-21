#!/bin/bash
set -euo pipefail

cleanup() {
  echo "🧹 Running cleanup..."
  [[ -n "${SSH_AGENT_PID:-}" ]] && ssh-agent -k > /dev/null || true
  rm -f ~/.ssh/id_rsa /etc/ssh/ssh_known_hosts || true
  unset SSH_PRIVATE_KEY
  unset SSH_KNOWN_HOSTS
  echo "✅ Cleanup done."
}
trap cleanup EXIT

# --- Setup SSH ---
mkdir -p ~/.ssh
chmod 700 ~/.ssh

echo "$SSH_PRIVATE_KEY" > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa
touch ~/.ssh/known_hosts

if [ -n "$SSH_KNOWN_HOSTS" ]; then
  echo "$SSH_KNOWN_HOSTS" > /etc/ssh/ssh_known_hosts
  chmod 644 /etc/ssh/ssh_known_hosts
  SSH_OPTIONS="-o StrictHostKeyChecking=yes -o UserKnownHostsFile=/etc/ssh/ssh_known_hosts"
else
  SSH_OPTIONS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
fi
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
whoami
REMOTE="$SSH_USER@$SSH_HOST"
REMOTE_DIR="${PROJECT_PATH:-~}"



echo "📦 Transferring files..."


ssh -p "$SSH_PORT" $SSH_OPTIONS "$REMOTE" "mkdir -p '$REMOTE_DIR'"

# Copy Deploy file
scp -P "$SSH_PORT" $SSH_OPTIONS "$DEPLOY_FILE" "$REMOTE:$REMOTE_DIR/"

# Copy extra files and directory
IFS=',' read -ra EXTRA <<< "$EXTRA_FILES"
for file in "${EXTRA[@]}"; do
  if [ -n "$file" ]; then
    echo "➡️ Copying $file to $REMOTE_DIR/$file"
    scp -P "$SSH_PORT" $SSH_OPTIONS -r "$file" "$REMOTE:$REMOTE_DIR/"
  fi
done


echo "🚀 Connecting to remote and deploying..."

ssh -p "$SSH_PORT" $SSH_OPTIONS "$REMOTE" << EOF
set -e
cd "$REMOTE_DIR"

# optional pre_command
if [ -n "$PRE_COMMAND" ]; then
  echo "▶️ Running pre_command..."
  eval "$PRE_COMMAND"
fi

DC_CMD="docker compose -f $DEPLOY_FILE"

if [ "$COMPOSE_PULL" = "true" ]; then
  echo "📥 Pulling images..."
  \$DC_CMD pull
fi

if [ "$COMPOSE_BUILD" = "true" ]; then
  echo "🔧 Building images..."
  \$DC_CMD build
fi

echo "📦 Starting containers..."
UP_CMD="\$DC_CMD up -d $COMPOSE_ARGS"
eval "\$UP_CMD"
echo "🔔 Used command: \$UP_CMD"


# optional post_command
if [ -n "$POST_COMMAND" ]; then
  echo "▶️ Running post_command..."
  eval "$POST_COMMAND"
fi
EOF

echo "✅ Deployment finished successfully!"