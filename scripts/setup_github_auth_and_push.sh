#!/usr/bin/env bash
# Install GitHub CLI, authenticate, and push the three Charybdis repos.
# Run this in WSL after migrating to a new drive / fresh install.

set -euo pipefail

REPOS=(
  /home/nos/charybdis/charybdis-tools
  /home/nos/charybdis/charybdis-zmk-config
  /home/nos/charybdis/charybdis-coach
)

echo "=== Installing GitHub CLI (gh) ==="
if ! command -v gh &>/dev/null; then
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
  sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
  sudo apt update
  sudo apt install gh -y
else
  echo "gh already installed: $(gh --version | head -1)"
fi

echo ""
echo "=== Authenticating with GitHub ==="
echo "Choose: GitHub.com -> HTTPS -> Yes -> Login with web browser (or token)"
gh auth login

echo ""
echo "=== Pushing commits ==="
for repo in "${REPOS[@]}"; do
  echo "--> $repo"
  cd "$repo"
  git push
  echo "    OK"
done

echo ""
echo "=== Done ==="
