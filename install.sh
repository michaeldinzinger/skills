#!/usr/bin/env bash
# Install (or update) my skill stack on this machine.
#
#   curl -fsSL https://raw.githubusercontent.com/michaeldinzinger/skills/main/install.sh | bash
#
# Options (pass after `bash -s --` when piping):
#   --no-external   skip third-party skills (external-skills.txt)
#   --no-plugins    skip Claude Code plugins (plugins.txt)
#
# Environment:
#   SKILLS_REPO     git URL to clone      (default: https://github.com/michaeldinzinger/skills.git)
#   SKILLS_HOME     where to clone it     (default: ~/.local/share/skill-stack)
#   SKILLS_TARGET   where to link skills  (default: ~/.claude/skills)
set -euo pipefail

SKILLS_REPO="${SKILLS_REPO:-https://github.com/michaeldinzinger/skills.git}"
SKILLS_TARGET="${SKILLS_TARGET:-$HOME/.claude/skills}"
WITH_EXTERNAL=1
WITH_PLUGINS=1

for arg in "$@"; do
  case "$arg" in
    --no-external) WITH_EXTERNAL=0 ;;
    --no-plugins)  WITH_PLUGINS=0 ;;
    -h|--help)     sed -n '2,15p' "$0" 2>/dev/null || true; exit 0 ;;
    *) echo "Unknown option: $arg" >&2; exit 1 ;;
  esac
done

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*" >&2; }

# 1. Find or fetch the repo. Run from a checkout -> use it; piped via curl -> clone/pull.
script_dir=""
if [[ -n "${BASH_SOURCE[0]:-}" && -f "${BASH_SOURCE[0]}" ]]; then
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

if [[ -n "$script_dir" && -d "$script_dir/skills" ]]; then
  REPO="$script_dir"
  info "Using checkout at $REPO"
else
  REPO="${SKILLS_HOME:-$HOME/.local/share/skill-stack}"
  if [[ -d "$REPO/.git" ]]; then
    info "Updating $REPO"
    git -C "$REPO" pull --ff-only --quiet
  else
    info "Cloning $SKILLS_REPO into $REPO"
    mkdir -p "$(dirname "$REPO")"
    git clone --quiet "$SKILLS_REPO" "$REPO"
  fi
fi

# 2. Symlink every skill in skills/ into the target dir, so `git pull` updates them in place.
mkdir -p "$SKILLS_TARGET"
backup_dir="$SKILLS_TARGET/.backup-$(date +%Y%m%d-%H%M%S)"
linked=0
for skill in "$REPO"/skills/*/; do
  skill="${skill%/}"
  name="$(basename "$skill")"
  dest="$SKILLS_TARGET/$name"
  if [[ -L "$dest" ]]; then
    rm "$dest"
  elif [[ -e "$dest" ]]; then
    mkdir -p "$backup_dir"
    mv "$dest" "$backup_dir/"
    warn "Moved existing $dest to $backup_dir/"
  fi
  ln -s "$skill" "$dest"
  linked=$((linked + 1))
done
info "Linked $linked skills into $SKILLS_TARGET"

# Drop links to skills that were removed from the repo.
for link in "$SKILLS_TARGET"/*; do
  if [[ -L "$link" && ! -e "$link" && "$(readlink "$link")" == "$REPO/skills/"* ]]; then
    rm "$link"
    info "Removed stale link $(basename "$link")"
  fi
done

# 3. Third-party skills via the skills CLI (https://skills.sh).
if [[ "$WITH_EXTERNAL" == 1 && -f "$REPO/external-skills.txt" ]]; then
  if command -v npx >/dev/null; then
    while read -r src name _; do
      [[ -z "$src" || "$src" == \#* ]] && continue
      info "Installing $name from $src"
      npx -y skills add "$src" --skill "$name" --agent claude-code -g -y </dev/null >/dev/null \
        || warn "Could not install $name from $src (no access?), skipping"
    done < "$REPO/external-skills.txt"
  else
    warn "npx not found, skipping third-party skills (install Node.js and re-run)"
  fi
fi

# 4. Claude Code plugins.
if [[ "$WITH_PLUGINS" == 1 && -f "$REPO/plugins.txt" ]]; then
  if command -v claude >/dev/null; then
    while read -r plugin marketplace _; do
      [[ -z "$plugin" || "$plugin" == \#* ]] && continue
      if [[ -n "${marketplace:-}" ]]; then
        claude plugin marketplace add "$marketplace" </dev/null >/dev/null 2>&1 || true
      fi
      info "Installing plugin $plugin"
      claude plugin install "$plugin" </dev/null >/dev/null \
        || warn "Could not install plugin $plugin, skipping"
    done < "$REPO/plugins.txt"
  else
    warn "claude not found, skipping plugins (install Claude Code and re-run)"
  fi
fi

info "Done. Restart Claude Code to pick up new skills."
