---
name: learn-by-play
description: Build interactive "learn by play" educational web content — single-page articles with embedded interactive widgets that teach technical concepts through hands-on exploration. Use this skill whenever someone wants to create an interactive explainer, technical tutorial with live demos, visual educational content, a concept showcase website, or any "teach through play" article. Also trigger when users mention interactive blogs, visual explainers, widget-based tutorials, or want to make technical documentation more engaging and hands-on. Covers the full pipeline from project setup through widget development to deployment.
---

# Learn by Play — Interactive Educational Content

This skill captures a proven methodology for building interactive educational websites where readers learn technical concepts by playing with live widgets embedded in explanatory prose. Think of it as the intersection of a technical blog post and an interactive playground.

The approach works for any technical domain: databases, ML/AI, networking, security, distributed systems, programming languages, etc. The key insight is that every abstract concept can be made tangible with the right interactive visualization.

## When to Use This Skill

- User wants to build an interactive explainer or tutorial
- User asks for a "visual" or "hands-on" way to teach a concept
- User wants to create educational content with embedded widgets
- User mentions the ngrok quantization blog, Distill.pub, or similar interactive articles
- User wants to make documentation more engaging
- User asks for a "learn by play" or "teach through play" experience

## Architecture

### Tech Stack
- **Framework**: Next.js (latest) with App Router
- **UI**: React 19 + TypeScript
- **Styling**: Tailwind CSS v4 + custom CSS classes
- **Fonts**: Inter (sans) + JetBrains Mono (mono) via Google Fonts
- **Deployment**: Static export to GitHub Pages (or any static host)

### Project Structure
```
src/
  app/
    page.tsx          # Layout + prose + widget imports (~200-300 lines)
    globals.css       # Theme + widget classes + animations
    layout.tsx        # Metadata + fonts
  components/
    widgets/
      index.ts        # Barrel export
      FooWidget.tsx   # One file per widget ("use client")
      BarWidget.tsx
```

Each widget is a self-contained `"use client"` component. The page.tsx file handles layout, navigation, prose, and imports widgets. This separation keeps things maintainable — widgets can be 200-600 lines each without cluttering the page.

### Why This Structure Matters
Putting widgets in separate files isn't just organization — it enables parallel development (multiple agents can build widgets simultaneously), independent testing, and reuse across pages. The barrel export makes imports clean: `import { FooWidget, BarWidget } from "@/components/widgets"`.

## Design System

### Dark Theme (the default — it makes visualizations pop)
```css
:root {
  --background: #0d0d0f;
  --foreground: #e4e4e7;
  --card: #18181b;
  --card-foreground: #e4e4e7;
  --border: rgba(255, 255, 255, 0.08);
  --muted-foreground: #a1a1aa;
}
```

### Widget Container
Every interactive widget lives inside a container with a gradient top accent border. This visually separates "reading" content from "playing" content:
```css
.widget-container {
  position: relative;
}
.widget-container::before {
  content: '';
  position: absolute;
  top: 0; left: 0; right: 0;
  height: 3px;
  background: linear-gradient(90deg, #22d3ee, #a78bfa, #f472b6);
  border-radius: 12px 12px 0 0;
  opacity: 0.6;
}
```
Usage: `className="widget-container bg-card border border-border rounded-xl p-6 my-8 overflow-hidden"`

### Widget Label
Each widget starts with a monospace label identifying what it is:
```jsx
<div className="text-xs text-muted-foreground uppercase tracking-wider mb-4 font-mono">
  Interactive · Widget Name Here
</div>
```

### Buttons
Monospace-styled buttons with active state for toggles/filters:
```css
.btn-mono {
  font-family: var(--font-mono);
  font-size: 0.78rem;
  padding: 0.35rem 0.85rem;
  border-radius: 6px;
  border: 1px solid var(--border);
  background: transparent;
  color: var(--muted-foreground);
  cursor: pointer;
  transition: all 0.15s;
}
.btn-mono:hover { background: rgba(255,255,255,0.05); color: var(--foreground); }
.btn-mono.active { background: rgba(255,255,255,0.1); color: var(--foreground); border-color: rgba(255,255,255,0.2); }
```

### Color-Coded Terminology
Each major concept gets its own color class, used consistently in prose and widgets:
```css
.text-concept-a { color: #f97316; font-weight: 600; }  /* orange */
.text-concept-b { color: #22d3ee; font-weight: 600; }  /* cyan */
.text-concept-c { color: #4ade80; font-weight: 600; }  /* green */
.text-concept-d { color: #a78bfa; font-weight: 600; }  /* purple */
.text-concept-e { color: #f472b6; font-weight: 600; }  /* pink */
```
Choose colors that are visually distinct and maintain WCAG contrast against #0d0d0f. Assign one color per concept and use it everywhere — in prose spans, widget highlights, and chart accents. This creates a visual vocabulary the reader builds up as they scroll.

### JSON Syntax Highlighting (for data-centric content)
```css
.json-key { color: #22d3ee; }
.json-string { color: #4ade80; }
.json-number { color: #f97316; }
.json-bracket { color: #71717a; }
.json-highlight { background: rgba(34,211,238,0.15); border-radius: 2px; }
```

### Illustration Palette (Pattern 12 only)
A second palette for `<IllustrationPlate />` and its presets. Isolated to plates — never apply these colors elsewhere or the warm/cool contrast that gives plates their character will dilute.
```css
:root {
  --illus-line: #f5ecd9;   /* cream stroke */
  --illus-shade: #3a3a40;  /* pencil shade */
}
```

### Sketch SVG Filter (Pattern 12 only)
Plates apply `filter="url(#sketch)"` to give crisp SVG paths a hand-drawn jitter via `<feTurbulence>` + `<feDisplacementMap>`. The filter definition lives in the `<SketchFilterDefs />` component (exported from `illustration-plate.tsx`) which the scaffold mounts in `layout.tsx`. If you author a project manually, mount it once near `<body>`.

### Animations
```css
/* Scroll-triggered reveal */
.reveal {
  opacity: 0; transform: translateY(30px);
  transition: opacity 0.7s ease-out, transform 0.7s ease-out;
}
.reveal.visible { opacity: 1; transform: translateY(0); }

/* Row highlight pulse */
@keyframes pulse-highlight {
  0% { background: rgba(34,211,238,0.3); }
  100% { background: transparent; }
}
.pulse-highlight { animation: pulse-highlight 0.8s ease-out; }

/* Slide-in for cards */
@keyframes slideInRight {
  from { opacity: 0; transform: translateX(20px); }
  to { opacity: 1; transform: translateX(0); }
}
.animate-slide-in { animation: slideInRight 0.4s ease-out both; }
```

### IntersectionObserver for Scroll Reveals
Add this to the main page component:
```jsx
useEffect(() => {
  const observer = new IntersectionObserver(
    (entries) => entries.forEach((e) => { if (e.isIntersecting) e.target.classList.add("visible"); }),
    { threshold: 0.1, rootMargin: "0px 0px -50px 0px" }
  );
  document.querySelectorAll(".reveal").forEach((el) => observer.observe(el));
  return () => observer.disconnect();
}, []);
```
Then add `className="reveal"` to each `<section>`.

## Content Structure

### Page Layout
```
<nav>          — Sticky, backdrop-blur, scrollable links on mobile
<hero>         — Gradient background + glow, title, subtitle with colored terms
<stats-strip>  — Optional. Handbook-style aggregate counts (chapters / widgets / read time / version)
<toc>          — Card with linked sections. Optionally grouped into chapters using <details>/<summary>
<section>*     — Repeated: heading → prose → widget → follow-up prose
<conclusion>   — Ties all concepts together
<footer>       — Attribution. Optionally include a <FooterMascot /> plate
```

### Optional: Stats Hero Strip
A row directly below the hero subtitle showing aggregate counts. Mirrors the "670+ pages, 300+ visualizations" callouts seen on cartesian.app. Hand-set props, not auto-counted. Uses `.stats-strip` styles from `starter-globals.css`. Example:

```jsx
<div className="stats-strip">
  <div><div className="stat-number">12</div><div className="stat-label">chapters</div></div>
  <div><div className="stat-number">47</div><div className="stat-label">widgets</div></div>
  <div><div className="stat-number">3 hr</div><div className="stat-label">read time</div></div>
  <div><div className="stat-number">v1.0</div><div className="stat-label">handbook</div></div>
</div>
```

### Optional: Expandable Hierarchical TOC
Group sections into chapters using native `<details>`/`<summary>` — zero JS, accessible by default. The `+`/`−` markers and chapter spacing are styled by `.toc summary` rules in `starter-globals.css`. Example:

```jsx
<nav className="toc">
  <details open>
    <summary>Chapter 1 · Foundations<span>3 sections · 8 widgets</span></summary>
    <ul>
      <li><a href="#concept-a">Concept A</a></li>
      <li><a href="#concept-b">Concept B</a></li>
    </ul>
  </details>
  <details>
    <summary>Chapter 2 · Internals<span>4 sections · 11 widgets</span></summary>
    <ul>{/* ... */}</ul>
  </details>
</nav>
```

The scaffold's generated `page.tsx` includes a `hashchange` listener that opens collapsed `<details>` when an inner section is targeted, so deep-link navigation works correctly.

### Section Pattern
Each section follows this rhythm — it's important for pacing:

1. **h2 heading** — Names the concept
2. **2-3 paragraphs** — Explains the concept in plain language, using colored terminology spans. Builds intuition before the reader touches anything.
3. **Interactive widget** — The "play" part. Reader can manipulate, explore, experiment.
4. **1-2 follow-up paragraphs** — Explains what the reader just saw. Connects to the bigger picture.

This "explain → play → reflect" rhythm is the core pedagogical pattern.

### Section Ordering
Flow from foundational to advanced. Earlier sections should introduce concepts that later sections build on. The conclusion should reference all concepts and show how they connect.

### Navigation
- Sticky nav with compact anchor links
- On mobile: `overflow-x-auto whitespace-nowrap` for horizontal scroll
- Hide verbose labels on small screens (use `hidden md:inline` for long text)

## Interactive Widget Patterns

These are the reusable patterns for building widgets. Choose the pattern that best fits each concept you want to teach.

### Pattern 1: Dual-View Sync
**Use when**: Two representations of the same data exist. Edit one, the other updates.
**Example**: Relational table ↔ JSON document, code ↔ visual output, source ↔ compiled.
**Layout**: `grid grid-cols-1 md:grid-cols-2 gap-px bg-border rounded-lg overflow-hidden`
**Key states**: `data`, `editingIndex`, `editValue`, `highlightedRow`
**Interaction**: Click to edit inline, changes reflect in both panes with pulse animation.
**Tip**: Use `useRef` + `useEffect` for input focus management, not `autoFocus` (which races with React renders). Add a 150ms delay on blur handlers to prevent premature save.

### Pattern 2: Cascading Updates (Slider-Driven)
**Use when**: Changing one parameter cascades through dependent values.
**Example**: Foreign key changes, configuration propagation, parameter tuning.
**Key states**: `paramValue` (range input), `highlighted` (pulse animation)
**Interaction**: Range slider with real-time feedback. Dependent values update instantly.

### Pattern 3: Interactive Graph (SVG)
**Use when**: Showing entity relationships, network topology, dependencies.
**Layout**: SVG viewBox with grid background, nodes as circles, edges as lines.
**Key states**: `hoveredNode`, `selectedNode`, `filter`
**Interaction**: Hover for tooltip, click to lock selection (dims unrelated nodes), filter buttons for node types.
**Color coding**: Different node types get different colors. Connected edges highlight on hover/select.
**Tip**: Use SVG `<defs>` with `<feDropShadow>` for glow effects on active nodes.

### Pattern 4: 3D Scatter / Vector Space (Canvas)
**Use when**: Showing spatial relationships, similarity, clustering, embeddings.
**Rendering**: HTML5 Canvas with 2D projection of 3D space.
**Key states**: `query` position, `k` (neighbors), `rotation`, `metric`
**Interaction**: Click to place query point, sliders for k and rotation, buttons for metric toggle.
**Projection**: Use separate `screenX`/`screenY` fields to avoid overwriting original coordinates.
**Tip**: Apply perspective consistently to both X and Y axes. Sort by depth (z) before rendering for proper occlusion.

### Pattern 5: Animated Pipeline (Multi-Stage)
**Use when**: Showing a process with sequential steps. RAG, ETL, build pipelines, request lifecycle.
**Layout**: Horizontal flex row of stage boxes connected by SVG arrows.
**Key states**: `stage` (current), `isAnimating`, `streamedText` (for typewriter output)
**Animation**: Chain `setTimeout` calls to advance stages. Each stage gets 1-2 seconds.
**Verbose output**: Show accumulated results below the pipeline as stages complete — embeddings, search scores, retrieved data, final output. This teaches by showing intermediate state, not just the final result.
**Tip**: Use `useRef` for timer cleanup to avoid memory leaks.

### Pattern 6: Split-Screen Comparison
**Use when**: Comparing two approaches, showing what goes wrong vs right.
**Layout**: Two-column grid with distinct header badges (green vs red/pink).
**Key states**: `scenario`, `step`, `isRunning`
**Animation**: Timeline entries appear one by one (300ms each). Success entries get green checkmarks, failure entries get red X or yellow warning.
**Tip**: Pre-define all scenarios as data arrays. Include a summary bar at the bottom counting anomalies/successes.

### Pattern 7: Neural Network / Flow Diagram (SVG)
**Use when**: Showing data flow through a system, ML inference, processing pipelines.
**Layout**: SVG with nodes (circles) connected by lines, inside a dashed "boundary" box.
**Key states**: `mode` (toggle), `activeRowIndex`, `activeLayer`, `latency`
**Animation**: Data rows flow through layers with cascading glow (200ms per layer).
**Mode toggle**: Switch between architectures (e.g., in-database vs traditional) to show different latency/security trade-offs.
**Tip**: Show realistic latency with a breakdown formula, not just a counter.

### Pattern 8: Tree Highlighting with Query Input
**Use when**: Teaching query languages, path expressions, selectors, filters.
**Layout**: Split-pane — tree visualization (left) + query input with results (right).
**Key states**: `query`, `matchedPaths`, `error`
**Interaction**: As user types (150ms debounce), matching tree nodes highlight in amber. Non-matching nodes dim.
**Pre-built examples**: Buttons that set the query to common expressions.
**Tip**: Reuse json-key/string/number/bracket classes for tree rendering. Build a simple parser that walks the tree recursively.

### Pattern 9: Index Construction + Animated Search (Canvas)
**Use when**: Teaching data structures, index building, search algorithms.
**Layout**: Canvas with nodes and edges, layer filter buttons.
**Key states**: `points`, `edges`, `searchPath`, `searchStep`, `activeLayer`
**Build phase**: "Add Point" button inserts points one at a time with edge connections.
**Search phase**: Animated greedy walk with step-by-step traversal, comparison counter.
**Tip**: Use geometric distribution for layer assignment. Show O(log n) vs O(n) comparison.

### Pattern 10: Code Playback Player
**Use when**: Teaching algorithm execution, recursion, state machines, anything where line-by-line variable changes are the lesson.
**Layout**: Two-column — source code (left), state inspector (right). Below: playback controls + scrubbable timeline.
**Key states**: `stepIndex`, `isPlaying`, `speed`
**Data**: Pre-baked `Trace` of `{ line, vars, stack?, heap?, note? }` objects. Authors hand-write or generate steps — no eval, no language-server dependency.
**Interaction**: ⏮ ◀ ▶/⏸ ▶ ⏭ buttons, range scrubber, speed selector (0.5×/1×/2×). Keyboard: `←`/`→` step, `space` play/pause.
**Visual cues**: Active line highlights in cyan; changed variables pulse via `.pulse-highlight`.
**Tip**: Use `useRef<ReturnType<typeof setInterval> | null>` and always clear in cleanup. Diff vars by `safeStringify` to mark changes correctly across non-JSON-safe values (functions, BigInts).
**Reference**: `references/playback-widget.tsx`.

### Pattern 11: Complexity / Big-O Comparison Chart
**Use when**: Comparing algorithmic complexity classes side-by-side (sort algorithms, search structures, hashing strategies).
**Layout**: SVG line chart (viewBox 600×360), legend toggle row above, range slider + n-indicator below, comparison table at the bottom.
**Key states**: `n`, `scale` (`"linear"` | `"log"`), `visible` (Set of curve labels)
**Data**: `curves: Curve[]` where each curve has `{ label, complexity, color, space? }`. Supported complexities: `O(1)`, `O(log n)`, `O(n)`, `O(n log n)`, `O(n^2)`, `O(2^n)`.
**Interaction**: LIN/LOG scale toggle, per-curve legend toggle, n slider with vertical guide line. Live ops count per curve in the table.
**Color coding**: Each curve's color should come from the project's terminology palette (`text-concept-*` hex values), so chart colors match prose colors.
**Tip**: Clamp `O(2^n)` at `Number.MAX_SAFE_INTEGER`; display as `> 2^53`. Use `Math.log10(v + 1)` for log scaling to handle zero-ops curves.
**Reference**: `references/complexity-chart.tsx`.

### Pattern 12: Annotated Illustration Plate
**Use when**: Adding visual warmth to a dark technical page — hero illustration, section dividers, footer mascot. Also for static system diagrams with labeled parts (pins reveal labels on hover/focus).
**Layout**: Inline SVG inside a `<figure class="widget-container">`. Optional pin overlay with numbered circles; tooltips show label + description on hover/focus/tap.
**Visual approach**: Rough-stroke SVG paths run through a `filter="url(#sketch)"` (`<feTurbulence>` + `<feDisplacementMap>`) for a hand-drawn feel without raster assets.
**Palette**: Uses a separate cream/pencil palette (`--illus-line: #f5ecd9`, `--illus-shade: #3a3a40`) isolated to plates so it doesn't bleed into the rest of the dark theme.
**Pre-built plates**: `<HeroPlate />` (open-book scene), `<DividerPlate />` (slim accent for between sections), `<FooterMascot />` (stylized character glyph).
**Setup requirement**: `<SketchFilterDefs />` must be mounted once near `<body>` so plates can reference the filter. The scaffold script mounts it in `layout.tsx` automatically.
**Tip**: Keep plates to ≤3 per page (hero, mid-divider, footer). The sketch filter is GPU-accelerated but more plates = more SVG nodes.
**Reference**: `references/illustration-plate.tsx`.

## Deployment

### Static Export Configuration
```typescript
// next.config.ts
const isProd = process.env.NODE_ENV === "production";
const nextConfig = {
  output: "export",
  basePath: isProd ? "/repo-name" : "",
  assetPrefix: isProd ? "/repo-name/" : "",
  images: { unoptimized: true },
};
```

### GitHub Pages Workflow
```yaml
# .github/workflows/deploy.yml
name: Deploy to GitHub Pages
on:
  push:
    branches: [main]
permissions:
  contents: read
  pages: write
  id-token: write
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 20, cache: npm }
      - run: npm ci
      - run: npm run build
      - uses: actions/upload-pages-artifact@v3
        with: { path: out }
  deploy:
    environment: { name: github-pages, url: "${{ steps.deployment.outputs.page_url }}" }
    runs-on: ubuntu-latest
    needs: build
    steps:
      - name: Deploy
        id: deployment
        uses: actions/deploy-pages@v4
```

## Implementation Checklist

When building a new learn-by-play project:

1. **Identify 5-9 concepts** to teach. Order from foundational to advanced.
2. **Assign colors** — one unique color per concept for consistent visual vocabulary.
3. **Choose widget patterns** — pick from the catalog above, matching each concept to the best interactive pattern.
4. **Set up the project** — Next.js + Tailwind + the CSS classes from the Design System section.
5. **Write widgets** — one file per widget in `src/components/widgets/`. Build in parallel if possible.
6. **Write the page** — hero, TOC, sections following the explain→play→reflect rhythm.
7. **Add scroll animations** — IntersectionObserver + reveal class on each section.
8. **Test each widget** — verify all interactions, check console for errors.
9. **Deploy** — static export + GitHub Pages (or any static host).

## Branding Customization

To brand for a specific organization:
- Replace the primary color in CSS variables (`--primary`)
- Update the nav logo (the small rounded box with a letter)
- Update the hero gradient to use brand colors
- Keep the dark theme — it makes interactive widgets visually striking and reduces eye strain for technical content

## Project Scaffolding

Run the scaffold script to bootstrap a new project with the full design system pre-configured:

```bash
bash /path/to/learn-by-play/scripts/scaffold.sh my-interactive-guide
```

This creates a Next.js project with the starter CSS, widget directory, barrel exports, scroll animations, and static export config already wired up. See `scripts/scaffold.sh` for details.

## Anti-Patterns to Avoid

These are mistakes that consistently produce poor results. Understanding why they fail helps you make better choices.

### Don't nest inputs inside buttons
Placing `<input>` elements inside `<button>` creates focus/blur race conditions — the input renders, gets autoFocus, then immediately blurs as the button click event completes. Instead, use conditional rendering: show the button OR the input, never one inside the other. Use `useRef` + `useEffect` for focus management, and add a ~150ms delay on blur handlers.

### Don't use `autoFocus` for dynamically rendered inputs
React's `autoFocus` prop races with the component mount cycle. Instead, use a ref and focus in a `useEffect` that depends on the editing state:
```jsx
const inputRef = useRef(null);
useEffect(() => {
  if (isEditing && inputRef.current) {
    inputRef.current.focus();
    inputRef.current.select();
  }
}, [isEditing]);
```

### Don't overwrite coordinates with projection
When projecting 3D points to 2D screen coordinates, never spread projected `{x, y}` over the original data point — it overwrites the data-space coordinates you need for distance calculations. Use distinct names: `screenX`, `screenY`, `depth`, `scale`.

### Don't use linear mapping for click-to-query in projected spaces
If your visualization applies rotation/perspective, click positions need inverse projection (e.g., Newton's method), not simple `clickX / canvasWidth` normalization. The mapping between screen and data space is nonlinear.

### Don't make all widgets the same complexity
Vary widget complexity to maintain pacing. A page of 9 equally complex widgets is exhausting. Mix simple sliders, medium interactive graphs, and one or two complex animated pipelines. The simpler widgets give readers a breather between dense sections.

### Don't hardcode demo values
Use seeded random generation so values change between runs while remaining deterministic within a run. This makes demos feel alive without being unpredictable. A `runId` counter + hash function works well.

### Don't put all widgets in one file
Extract each widget to its own `"use client"` file. A 3000-line page.tsx is unmaintainable and prevents parallel development. Keep page.tsx under 300 lines (imports + layout + prose).

### Don't forget mobile
- Nav links overflow on mobile — use `overflow-x-auto whitespace-nowrap scrollbar-hide`
- Widget split-panes should collapse to single column: `grid-cols-1 md:grid-cols-2`
- Hero h1 should be responsive: `text-3xl md:text-5xl`
- Canvas/SVG widths should use `w-full` with fixed aspect ratios

## Version History

- **v1.1.0** (2026-05-18): Cartesian-inspired visual expansion.
  - Pattern 10: Code Playback Player (stepped execution + state inspector with scrubbable timeline)
  - Pattern 11: Complexity / Big-O Comparison Chart (live ops counts per curve at draggable n)
  - Pattern 12: Annotated Illustration Plate (rough-stroke SVG via sketch filter + pin overlay, plus `<HeroPlate />`, `<DividerPlate />`, `<FooterMascot />` presets)
  - Optional Expandable Hierarchical TOC using native `<details>`/`<summary>`
  - Optional Stats Hero Strip for handbook-style aggregate counts
  - New design tokens: illustration palette (`--illus-line`, `--illus-shade`), playback controls, TOC styles, stats strip
  - Reference React implementations shipped in `references/` and wired into `scripts/scaffold.sh`
  - No breaking changes to Patterns 1–9.
- **v1.0.0** (2026-04-01): Initial release. 9 widget patterns, dark theme design system, deployment config. Developed while building the Oracle AI Database interactive showcase (github.com/jasperan/visual-oracledb).
