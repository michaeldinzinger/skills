# skills

My personal skill stack for [Claude Code](https://claude.com/claude-code): the global skills I use on every machine, plus the third-party skills and plugins I rely on. Inspired by [Matt Pocock's skills](https://github.com/mattpocock/skills) and similar collections.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/michaeldinzinger/skills/main/install.sh | bash
```

That's it. Restart Claude Code afterwards. Run the same command again any time to update.

What it does:

1. Clones this repo to `~/.local/share/skill-stack` (or pulls it if it is already there).
2. Symlinks every folder in [`skills/`](skills) into `~/.claude/skills/`. If a real folder with the same name is already there, it is moved to `~/.claude/skills/.backup-<timestamp>/` first.
3. Installs the third-party skills listed in [`external-skills.txt`](external-skills.txt) with the [`skills` CLI](https://skills.sh) (needs Node.js / `npx`).
4. Installs the Claude Code plugins listed in [`plugins.txt`](plugins.txt) (needs `claude` on the `PATH`).

Steps 3 and 4 are skipped with a warning if the tool is missing, and any single skill or plugin that fails to install is skipped without stopping the rest.

### Options

```bash
# only my own skills, no third-party skills or plugins
curl -fsSL https://raw.githubusercontent.com/michaeldinzinger/skills/main/install.sh | bash -s -- --no-external --no-plugins
```

| Option / variable | Default | Effect |
| --- | --- | --- |
| `--no-external` | | skip `external-skills.txt` |
| `--no-plugins` | | skip `plugins.txt` |
| `SKILLS_HOME` | `~/.local/share/skill-stack` | where the repo is cloned |
| `SKILLS_TARGET` | `~/.claude/skills` | where skills are linked |
| `SKILLS_REPO` | `https://github.com/michaeldinzinger/skills.git` | repo to clone (e.g. the SSH URL) |

### Working from a checkout

If you already have the repo cloned (e.g. to edit skills), run the script from there instead. It then links to that checkout and does not clone a second copy:

```bash
git clone git@github.com:michaeldinzinger/skills.git ~/GitHub/skills
~/GitHub/skills/install.sh
```

## My skills

| Skill | What it does |
| --- | --- |
| [`rp-lead`](skills/rp-lead/SKILL.md) | Claude takes the project-lead role: orients from handoff/status docs, delegates to subagents, and brings me only decisions in a fixed decision-card format. |
| [`rp-interview-me`](skills/rp-interview-me/SKILL.md) | Structured interview to pin down every detail of a research project and write it into a spec agents can execute from. |
| [`rp-review-pre-paper-writing`](skills/rp-review-pre-paper-writing/SKILL.md) | Critical review of a research project right before writing the paper: does it carry a clear narrative, where are the limits, what would make it extraordinary. |
| [`rp-status`](skills/rp-status/SKILL.md) | Create or update a concise status page: goal, research questions, results, open decisions, next steps. |
| [`session-handoff`](skills/session-handoff/SKILL.md) | Write a throwaway `HANDOFF.md` for the next session, or consume and delete one. |
| [`pr-description`](skills/pr-description/SKILL.md) | Generate a concise PR description from a PR, branch or diff as copyable markdown. |

## Third-party skills and plugins

From [`external-skills.txt`](external-skills.txt):

| Skill | Source |
| --- | --- |
| `interview-me`, `code-review-and-quality` | [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) |
| `find-skills` | [vercel-labs/skills](https://github.com/vercel-labs/skills) |

From [`plugins.txt`](plugins.txt):

| Plugin | Marketplace |
| --- | --- |
| `mattpocock-skills` | `claude-plugins-official` |
| `typesafe` | [typesafe-ai/skills](https://github.com/typesafe-ai/skills) |

## Adding or changing a skill

- **Own skill:** create `skills/<name>/SKILL.md` (with `name` and `description` frontmatter), commit, push, and re-run the install command on each machine. Edits to existing skills only need a `git pull`, since the installed skills are symlinks into the repo.
- **Third-party skill:** add a line `<owner/repo> <skill-name>` to `external-skills.txt`.
- **Plugin:** add a line `<plugin>@<marketplace> [<marketplace-repo>]` to `plugins.txt`.

To remove one of my skills, delete its folder and re-run the installer. It cleans up links to skills that no longer exist.
