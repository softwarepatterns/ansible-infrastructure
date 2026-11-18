#!/usr/bin/env bash
# gate.sh — static gate for softwarepatterns.infrastructure (level 1).
#
# Purpose: prove the collection skeleton (and any future roles) is
#   internally consistent. No network beyond venv bootstrap; no secrets.
# Invariants:
#   - Public, generic: no secrets or unexposed hostnames in roles/plugins.
#   - Every present role dir has README + defaults + tasks + meta + molecule.
#   - Commit hook ≡ push hook (.githooks/).
set -euo pipefail
cd "$(dirname "$0")/.."
ROOT="$(pwd)"

say() { printf 'gate: %s\n' "$*"; }

say "shell syntax"
fail=0
while IFS= read -r -d '' f; do
  bash -n "$f" || { echo "bash -n failed: $f"; fail=1; }
done < <(find . -path ./.git -prune -o -path ./.venv-gate -prune -o -name '*.sh' -print0)
[ "$fail" -eq 0 ] || exit 1

say "venv bootstrap"
if [ ! -x "$ROOT/.venv-gate/bin/python" ]; then
  python3 -m venv "$ROOT/.venv-gate"
  "$ROOT/.venv-gate/bin/pip" install -q -r requirements.txt
fi

say "galaxy manifest"
missing="$(
  "$ROOT/.venv-gate/bin/python" - <<'PY'
import yaml
with open("galaxy.yml", "r", encoding="utf-8") as f:
    data = yaml.safe_load(f)
data = data or {}
required = ["namespace", "name", "version", "readme", "license"]
print(" ".join(k for k in required if k not in data))
PY
)"
if [ -n "$missing" ]; then
  echo "galaxy.yml missing required key(s): $missing" >&2
  exit 1
fi

say "collection build"
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
# ansible-galaxy may refuse non-blocking pipes (git hooks); log to a file.
if ! "$ROOT/.venv-gate/bin/ansible-galaxy" collection build --output-path "$tmpdir" . >"$tmpdir/build.log" 2>&1; then
  echo "collection build failed:" >&2
  cat "$tmpdir/build.log" >&2
  exit 1
fi

say "artifact contents"
tarball="$(find "$tmpdir" -name '*.tar.gz' | head -1)"
if [ -z "$tarball" ]; then
  echo "no .tar.gz produced by collection build" >&2
  exit 1
fi
banned="$(tar -tzf "$tarball" | grep -E '^\.(molecule|ansible|forgejo)/|^AGENTS\.md$' || true)"
if [ -n "$banned" ]; then
  echo "repo-local machinery leaked into the tarball:" >&2
  echo "$banned" >&2
  exit 1
fi
if ! tar -tzf "$tarball" | grep -qx '.agents/references/sshd-stale-config.md'; then
  echo ".agents/references/sshd-stale-config.md missing from the tarball" >&2
  exit 1
fi

say "role completeness"
missing=""
shopt -s nullglob
for role in roles/*/; do
  [ -d "$role" ] || continue
  for req in README.md defaults/main.yml tasks/main.yml meta/main.yml; do
    [ -f "$role$req" ] || missing="$missing${role}${req}"$'\n'
  done
  if ! find "$role"molecule -type f -name 'molecule.yml' -print -quit 2>/dev/null | grep -q .; then
    missing="$missing${role}molecule/*/molecule.yml"$'\n'
  fi
done
shopt -u nullglob
if [ -n "$missing" ]; then
  printf 'role completeness — missing paths:\n%s' "$missing" >&2
  exit 1
fi

say "no secrets in shipped code"
if grep -rEn 'BEGIN (OPENSSH|RSA|EC|DSA|ENCRYPTED) PRIVATE KEY|(api_key|access_key|secret_key|token|password|passwd)[[:space:]]*[:=][[:space:]]*[A-Za-z0-9._/+=]{6,}' roles/ plugins/ 2>/dev/null; then
  echo "secret material found in shipped code (see above)" >&2
  exit 1
fi
if find . -path ./.git -prune -o -path ./.venv-gate -prune -o \
     \( -name '.env' -o -name '.env.enc' -o -name '*.pem' -o -name 'id_rsa' -o -name 'id_ed25519' \) -print \
   | grep -q .; then
  echo "secret-bearing filename found (.env / .env.enc / *.pem / id_rsa / id_ed25519)" >&2
  exit 1
fi

say "no internal names in shipped code"
# forgejo.softwarepatterns.com is this repo's public home (galaxy.yml).
# Ban unexposed estate machine names/IPs in shipped role/plugin code.
if grep -rEn 'builder\.softwarepatterns\.com|vultr-lax-builder|45\.32\.72\.238' \
     roles/ plugins/ 2>/dev/null; then
  echo "internal hostnames/IPs found in shipped code (see above)" >&2
  exit 1
fi

say "ansible-lint"
if compgen -G "roles/*/" > /dev/null; then
  ANSIBLE_HOME="$ROOT/.venv-gate/ansible-home" "$ROOT/.venv-gate/bin/ansible-lint" roles/ || exit 1
else
  say "ansible-lint (skipped — no roles)"
fi

say "ok"
