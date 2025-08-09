#!/usr/bin/env bash
set -euo pipefail
OWNER="Sianlk"
REPO="Gitgit"
TOKEN="$(cat .secrets/GH_PAT)"
API="https://api.github.com/repos/${OWNER}/${REPO}"

# find or create the seed issue
ISSUE_NUM="$(curl -s -H "Authorization: token ${TOKEN}" "${API}/issues?state=open&per_page=100" \
  | jq -r '[.[] | select(.title=="Seed bot")] | .[0].number // empty')"
if [ -z "${ISSUE_NUM}" ]; then
  ISSUE_NUM="$(curl -s -H "Authorization: token ${TOKEN}" -d '{"title":"Seed bot","body":"Use `/seed key=value` here"}' \
    "${API}/issues" | jq -r .number)"
fi

# build the /seed payload from CLI args, e.g. ./va_seed.sh 'price=625000 rent=2600 note="update"'
PAYLOAD="/seed ${*:-note=\"refresh\"}"

curl -s -H "Authorization: token ${TOKEN}" -H "Accept: application/vnd.github+json" \
  -d "$(jq -rn --arg body "$PAYLOAD" '{body:$body}')" \
  "${API}/issues/${ISSUE_NUM}/comments" >/dev/null

echo "Seed comment posted to issue #${ISSUE_NUM}: ${PAYLOAD}"
