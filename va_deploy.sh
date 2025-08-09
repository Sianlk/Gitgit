#!/usr/bin/env bash
set -euo pipefail
date -u > .deploy_touch
git add .deploy_touch
git commit -m "deploy: touch $(date -u)" || echo "no changes"
git push
echo "Pushed. Pages will redeploy in ~1–3 minutes."
