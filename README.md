# skills

My personal skill stack for [Claude Code](https://claude.com/claude-code): the global skills I use on every machine, plus the third-party skills and plugins I rely on. Inspired by [Matt Pocock's skills](https://github.com/mattpocock/skills) and similar collections.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/michaeldinzinger/skills/main/install.sh | bash
```

Restart Claude Code afterwards (or run `/reload-plugins`). Run the same command again any time to update. The only requirement is Claude Code itself. The script finds it in `~/.local/bin` even when that is not on your `PATH` yet.

This repo is a Claude Code [plugin marketplace](.claude-plugin/marketplace.json) called `michaeldinzinger`. The script:

1. Adds the marketplace (or updates it, if it is already there).
2. Installs the `stack` plugin. It has no skills of its own. Its [dependencies](stack/.claude-plugin/plugin.json) pull in everything else: my own skills (`skill-stack`) and the third-party plugins below.
3. Updates every installed plugin from the marketplace, so they move to the commits pinned in `marketplace.json`.
4. Cleans up what the old symlink/`npx` installer left behind. It removes old symlinks, moves old `npx skills` copies to `~/.local/share/skill-stack-backups/`, and uninstalls the unpinned `mattpocock-skills@claude-plugins-official` and `typesafe@typesafe-ai`.

If a step fails, the script prints the error from `claude`, goes on where that makes sense, and exits non-zero.

Without the script, the same thing is:

```bash
claude plugin marketplace add michaeldinzinger/skills
claude plugin install stack@michaeldinzinger
```

### Options

```bash
# pass options after `bash -s --` when piping
curl -fsSL https://raw.githubusercontent.com/michaeldinzinger/skills/main/install.sh | bash -s -- --dry-run
```

| Option / variable | Effect |
| --- | --- |
| `--only-mine` | install only `skill-stack` (my own skills), no third-party plugins |
| `--dry-run` | print what would change, change nothing |
| `--uninstall` | uninstall all plugins from this marketplace, prune them, remove the marketplace |
| `SKILLS_MARKETPLACE` | marketplace source (default: the checkout when run from one, else `michaeldinzinger/skills`) |
| `CLAUDE_BIN` | path to `claude`, if the script cannot find it |

Skills from plugins are namespaced by plugin, e.g. `skill-stack:rp-lead`. They still trigger on their descriptions as before.

### Working from a checkout

Run the script from a clone to edit skills:

```bash
git clone git@github.com:michaeldinzinger/skills.git ~/GitHub/skills
~/GitHub/skills/install.sh
```

The marketplace then points at the checkout, and Claude Code loads `skill-stack` from it in place. Edits take effect at the next session start or after `/reload-plugins`, with no push or reinstall needed. Run the curl command again to switch back to GitHub.

## My skills

| Skill | What it does |
| --- | --- |
| [`rp-lead`](skills/rp-lead/SKILL.md) | Claude takes the project-lead role: orients from handoff/status docs, delegates to subagents, and brings me only decisions in a fixed decision-card format. |
| [`rp-interview-me`](skills/rp-interview-me/SKILL.md) | Structured interview to pin down every detail of a research project and write it into a spec agents can execute from. |
| [`rp-review-pre-paper-writing`](skills/rp-review-pre-paper-writing/SKILL.md) | Critical review of a research project right before writing the paper: does it carry a clear narrative, where are the limits, what would make it extraordinary. |
| [`rp-status`](skills/rp-status/SKILL.md) | Create or update a concise status page: goal, research questions, results, open decisions, next steps. |
| [`session-handoff`](skills/session-handoff/SKILL.md) | Write a throwaway `HANDOFF.md` for the next session, or consume and delete one. |
| [`pr-description`](skills/pr-description/SKILL.md) | Generate a concise PR description from a PR, branch or diff as copyable markdown. |

## Third-party plugins

Listed in [`.claude-plugin/marketplace.json`](.claude-plugin/marketplace.json), each pinned to a commit (`sha`):

| Plugin | Skills | Source |
| --- | --- | --- |
| `agent-skills` | `interview-me`, `code-review-and-quality` | [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) |
| `find-skills` | `find-skills` | [vercel-labs/skills](https://github.com/vercel-labs/skills) |
| `mattpocock-skills` | all of the plugin | [mattpocock/skills](https://github.com/mattpocock/skills) |
| `typesafe` | all of the plugin | [typesafe-ai/skills](https://github.com/typesafe-ai/skills) |

Pinning means a push to one of those repos changes nothing here until I move the pin. To update one:

1. Look at what changed: `git log -p <old-sha>..<new-sha>` in that repo.
2. Put the new `sha` in `marketplace.json`, commit, push, and re-run the installer.

`mattpocock-skills` and `typesafe` take their version from their own `plugin.json`. Claude Code only updates them when that version changes. If you move the pin and the installer does not pick it up, upstream did not bump the version: run `claude plugin uninstall <plugin>@michaeldinzinger` and re-run the installer. `agent-skills` and `find-skills` are versioned by commit, so any pin move updates them.

## Adding or changing things

- **Own skill:** create `skills/<name>/SKILL.md` (with `name` and `description` frontmatter), commit, push, re-run the installer. The `skill-stack` plugin picks up every folder in `skills/`.
- **Skills from another repo:** add a `git-subdir` entry to `marketplace.json` with `path` set to the folder that holds the skills, `skills` listing the ones you want, and a `sha`. Then add its name to `dependencies` in [`stack/.claude-plugin/plugin.json`](stack/.claude-plugin/plugin.json). Do not point a `strict: false` entry at a repo that has its own `plugin.json`: it fails to load with "conflicting manifests".
- **A whole plugin:** add an entry with a `url` source and a `sha`, and add it to `dependencies`.
- **Check before pushing:** `claude plugin validate .`

To remove something, take it out of `marketplace.json` and `dependencies`, then run `claude plugin uninstall <name>@michaeldinzinger`.
