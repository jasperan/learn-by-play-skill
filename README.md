# Learn by Play - Claude Code Skill

A Claude Code skill for building interactive "learn by play" educational web content. Creates single-page articles with embedded interactive widgets that teach technical concepts through hands-on exploration.

## What it does

This skill guides Claude to build interactive educational websites where readers learn by playing with live widgets embedded in explanatory prose. It encodes:

- **Architecture**: Next.js + React 19 + TypeScript + Tailwind CSS v4
- **Dark theme design system** with gradient widget containers, monospace buttons, color-coded terminology
- **9 reusable widget patterns**: dual-view sync, cascading updates, graph visualization, 3D vector scatter, animated pipelines, split-screen comparisons, neural network flows, tree highlighting, index construction
- **Content structure**: explain -> play -> reflect rhythm with scroll-triggered animations
- **Deployment**: Static export to GitHub Pages

## Install

Copy the `SKILL.md` and `references/` directory to your Claude Code skills folder:

```bash
# Global install
cp -r . ~/.claude/skills/learn-by-play

# Or project-scoped
cp -r . your-project/.claude/skills/learn-by-play
```

## Usage

The skill triggers automatically when you ask Claude to build interactive educational content. Examples:

- "Build an interactive explainer about how TCP/IP works"
- "Create a visual tutorial for Kubernetes networking with live widgets"
- "Make a learn-by-play article about how compilers work"

## Example

This skill was developed while building [visual-oracledb](https://github.com/jasperan/visual-oracledb) — an interactive showcase of Oracle AI Database capabilities with 9 interactive widgets.

Live demo: [jasperan.github.io/visual-oracledb](https://jasperan.github.io/visual-oracledb/)

## License

MIT
