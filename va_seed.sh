#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./va_seed.sh 'addr="58 Chester Road, Hounslow TW4 6HX" price=625000 rent=2600 note="planning refs"'
#
# Effect:
#   - creates/updates properties/<slug>/index.html
#   - commits + pushes
#   - auto-deploys (calls ./va_deploy.sh if present; otherwise does a touch/commit to trigger Pages)

# --- parse one quoted argument containing k=v pairs ---
[[ $# -eq 1 ]] || { echo "Usage: $0 'addr=\"...\" price=... rent=... note=\"...\"'"; exit 1; }
eval "$1"  # sets: addr price rent note

: "${addr:?addr required}"
price="${price:-}"
rent="${rent:-}"
note="${note:-}"

# --- helpers ---
slugify() {
  # to lowercase, replace non-alnum with -, squeeze -, trim -
  echo "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/-+/-/g; s/^-|-$//g'
}

iso_date="$(date -u +%Y-%m-%d)"
slug="$(slugify "$addr")"
dir="properties/${slug}"
page="${dir}/index.html"

# --- ensure folder tracked ---
mkdir -p "$dir"
# if .gitignore accidentally ignores properties/, remove that line
if grep -qE '^\s*properties/?\s*$' .gitignore 2>/dev/null; then
  sed -i '/^\s*properties\/\s*$/d' .gitignore
fi

# --- write page ---
cat > "$page" <<EOF
<!doctype html>
<meta charset="utf-8">
<title>${addr} — seeded ${iso_date}</title>
<h1>${addr}</h1>
<ul>
  <li><b>Guide price:</b> ${price}</li>
  <li><b>Guide rent (pcm):</b> ${rent}</li>
  <li><b>Notes:</b> ${note}</li>
  <li><small>Seeded ${iso_date}</small></li>
</ul>
EOF

# --- lightweight index page (landing) ---
index_root="index.html"
if [ ! -s "$index_root" ]; then
  cat > "$index_root" <<EOF
<!doctype html>
<meta charset="utf-8">
<title>Gitgit</title>
<h1>Gitgit</h1>
<p>Automated property seeds.</p>
<ul>
  <li><a href="properties/${slug}/">Latest: ${addr}</a></li>
</ul>
EOF
else
  # ensure link for this property exists (idempotent)
  if ! grep -F "properties/${slug}/" "$index_root" >/dev/null; then
    # insert link before closing </ul> if present, else append
    if grep -n '</ul>' "$index_root" >/dev/null; then
      awk -v link="  <li><a href=\"properties/${slug}/\">${addr}</a></li>" '
        /<\/ul>/ && !ins { print link; ins=1 } { print }
      ' "$index_root" > "$index_root.tmp" && mv "$index_root.tmp" "$index_root"
    else
      echo "<p><a href=\"properties/${slug}/\">${addr}</a></p>" >> "$index_root"
    fi
  fi
fi

# --- commit & push ---
git add "$page" "$index_root" .gitignore 2>/dev/null || true
git commit -m "seed: ${addr} (price=${price} rent=${rent})" || true
git push -u origin "$(git rev-parse --abbrev-ref HEAD)"

# --- auto-deploy ---
if [ -x ./va_deploy.sh ]; then
  echo "🔄 Running ./va_deploy.sh …"
  ./va_deploy.sh
else
  echo "🔄 Touching to trigger Pages deploy …"
  date -u > .deploy_touch
  git add .deploy_touch
  git commit -m "deploy: touch $(date -u +%Y-%m-%dT%H:%M:%SZ)" || true
  git push
fi

echo "✅ Seeded & queued deploy:
 • Page: properties/${slug}/
 • Address: ${addr}"
