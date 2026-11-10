#!/usr/bin/env bash

git config --global --add safe.directory /xyz

# Fresh Docker volumes are root-owned; hand them to container-user first.
sudo chown -R container-user:container-user \
  "$HOME/.claude" \
  "$HOME/.gemini" \
  "$HOME/.ssh" \
  "$HOME/.sshtemplate" 2>/dev/null || true