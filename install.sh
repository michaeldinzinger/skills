#!/usr/bin/env bash
# Install (or update) my skill stack as Claude Code plugins.
#
#   curl -fsSL https://raw.githubusercontent.com/michaeldinzinger/skills/main/install.sh | bash
#
# Options (pass after `bash -s --` when piping):
#   --only-mine   install only my own skills (skill-stack), no third-party plugins
#   --uninstall   remove everything this script installed
#   --dry-run     print what would change, change nothing
#
# Environment:
#   SKILLS_MARKETPLACE  marketplace source (default: this checkout when run from one,
#                       else michaeldinzinger/skills on GitHub)
#   CLAUDE_BIN          path to the claude binary, if it is not on PATH
set -uo pipefail  # no -e: run() reports failures and the script goes on

MARKETPLACE=michaeldinzinger
TARGET=stack
UNINSTALL=0
DRY_RUN=0

for arg in "$@"; do
  case "$arg" in
    --only-mine) TARGET=skill-stack ;;
    --uninstall) UNINSTALL=1 ;;
    --dry-run)   DRY_RUN=1 ;;
    -h|--help)   sed -n '2,15p' "$0" 2>/dev/null || true; exit 0 ;;
    *) echo "Unknown option: $arg" >&2; exit 1 ;;
  esac
done

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*" >&2; }
failures=0

# Run a command. Keep quiet on success; on failure show its output and go on.
run() {
  if (( DRY_RUN )); then printf '    would run: %s\n' "$*"; return 0; fi
  local out
  if out=$("$@" </dev/null 2>&1); then return 0; fi
  warn "Failed: $*"
  printf '%s\n' "$out" | sed 's/^/    /' >&2
  failures=$((failures + 1))
  return 1
}

# Find a tool even when it is not on PATH. `curl | bash` does not read ~/.bashrc,
# and on Ubuntu ~/.profile only adds ~/.local/bin if it existed at login, so a fresh
# Claude Code install is often invisible here.
find_tool() {
  local name="$1" p; shift
  for p in "$(command -v "$name" 2>/dev/null || true)" "$@"; do
    if [[ -n "$p" && -x "$p" ]]; then echo "$p"; return 0; fi
  done
  return 1
}

if ! CLAUDE=$(find_tool claude "${CLAUDE_BIN:-}" "$HOME/.local/bin/claude" \
                               "$HOME/.claude/local/claude" "$HOME/.npm-global/bin/claude"); then
  warn "claude not found. Install Claude Code (https://claude.com/claude-code), or set CLAUDE_BIN, and re-run."
  exit 1
fi
claude() { "$CLAUDE" "$@"; }

# Plugin ids from this marketplace that are installed now, e.g. "stack@michaeldinzinger".
installed() { claude plugin list --json 2>/dev/null | grep -o "\"[a-z0-9-]*@$MARKETPLACE\"" | tr -d '"' | sort -u || true; }
is_installed() { claude plugin list --json 2>/dev/null | grep -qF "\"$1\""; }
has_marketplace() { claude plugin marketplace list --json 2>/dev/null | grep -qF "\"name\": \"$MARKETPLACE\""; }

# --- Uninstall ---------------------------------------------------------------
if (( UNINSTALL )); then
  for id in $(installed); do info "Uninstalling $id"; run claude plugin uninstall "$id"; done
  run claude plugin prune -y || true
  if has_marketplace; then info "Removing marketplace $MARKETPLACE"; run claude plugin marketplace remove "$MARKETPLACE"; fi
  info "Done."
  exit $(( failures > 0 ))
fi

# --- Marketplace source --------------------------------------------------------
# From a checkout, use the checkout itself: Claude Code then loads my skills in place,
# so edits take effect at the next session start (or /reload-plugins).
script_dir=""
if [[ -n "${BASH_SOURCE[0]:-}" && -f "${BASH_SOURCE[0]}" ]]; then
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi
if [[ -n "${SKILLS_MARKETPLACE:-}" ]]; then
  SOURCE="$SKILLS_MARKETPLACE"
elif [[ -n "$script_dir" && -f "$script_dir/.claude-plugin/marketplace.json" ]]; then
  SOURCE="$script_dir"
else
  SOURCE=michaeldinzinger/skills
fi
if [[ -d "$SOURCE" ]]; then
  SOURCE="$(cd "$SOURCE" && pwd)"
  source_key="\"path\": \"$SOURCE\""
else
  source_key="\"repo\": \"$SOURCE\""
fi

# --- Clean up what the old symlink/npx installer left behind -----------------------
SKILLS_DIR="$HOME/.claude/skills"
BACKUP="$HOME/.local/share/skill-stack-backups/$(date +%Y%m%d-%H%M%S)"

for name in pr-description rp-interview-me rp-lead rp-review-pre-paper-writing rp-status session-handoff; do
  link="$SKILLS_DIR/$name"
  if [[ -L "$link" && "$(readlink "$link")" == */skills/"$name" ]]; then
    info "Removing old symlink $link (now part of the skill-stack plugin)"
    run rm "$link"
  fi
done
# Copies that `npx skills add` made. Moved, not deleted.
for name in interview-me code-review-and-quality find-skills; do
  dir="$SKILLS_DIR/$name"
  if [[ -d "$dir" && ! -L "$dir" && -f "$dir/SKILL.md" ]]; then
    info "Moving old copy $dir to $BACKUP/ (now a pinned plugin)"
    run mkdir -p "$BACKUP" && run mv "$dir" "$BACKUP/"
  fi
done
# Plugins the old installer took from other marketplaces, unpinned.
for id in mattpocock-skills@claude-plugins-official typesafe@typesafe-ai; do
  if is_installed "$id"; then
    info "Uninstalling $id (replaced by the pinned copy in $MARKETPLACE)"
    run claude plugin uninstall "$id"
  fi
done
if [[ -d "$HOME/.local/share/skill-stack/.git" ]]; then
  warn "The old clone at ~/.local/share/skill-stack is no longer used. Delete it when you like."
fi

# --- Marketplace and plugins ---------------------------------------------------
if has_marketplace; then
  if claude plugin marketplace list --json 2>/dev/null | grep -qF "$source_key"; then
    info "Updating marketplace $MARKETPLACE"
    run claude plugin marketplace update "$MARKETPLACE"
  else
    warn "Marketplace $MARKETPLACE points to another source; switching it to $SOURCE"
    run claude plugin marketplace remove "$MARKETPLACE"
    run claude plugin marketplace add "$SOURCE"
  fi
else
  info "Adding marketplace $MARKETPLACE from $SOURCE"
  run claude plugin marketplace add "$SOURCE"
fi

if (( failures )); then warn "Could not set up marketplace $MARKETPLACE, stopping."; exit 1; fi

# install also adds dependencies that are new since the last run.
info "Installing $TARGET@$MARKETPLACE"
run claude plugin install "$TARGET@$MARKETPLACE"

# update moves already-installed plugins to the commits pinned in marketplace.json.
for id in $(installed); do
  run claude plugin update "$id" || true
done

if (( DRY_RUN )); then
  info "Dry run, nothing changed."
elif (( failures )); then
  warn "Done with $failures failure(s), see above. Fix them and re-run."
  exit 1
else
  info "Done. Installed: $(installed | tr '\n' ' ')"
  info "Restart Claude Code, or run /reload-plugins in an open session."
fi
