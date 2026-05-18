#!/bin/bash
# Learn-by-Play Project Scaffolder
# Usage: bash scaffold.sh <project-name> [num-sections]
#
# Creates a new Next.js project with the learn-by-play design system pre-configured.

set -e

PROJECT_NAME="${1:?Usage: bash scaffold.sh <project-name> [num-sections]}"
NUM_SECTIONS="${2:-5}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"

echo "🎮 Scaffolding learn-by-play project: $PROJECT_NAME"

# Create Next.js project
npx create-next-app@latest "$PROJECT_NAME" \
  --typescript \
  --tailwind \
  --app \
  --src-dir \
  --no-import-alias \
  --use-npm \
  --yes

cd "$PROJECT_NAME"

# Install additional dependencies
npm install tw-animate-css clsx tailwind-merge lucide-react

# Copy starter CSS
if [ -f "$SKILL_DIR/references/starter-globals.css" ]; then
  cp "$SKILL_DIR/references/starter-globals.css" src/app/globals.css
  echo "✅ Copied starter globals.css"
fi

# Create widgets directory
mkdir -p src/components/widgets

# Copy reference widgets if present
mkdir -p src/components/widgets
for w in playback-widget complexity-chart illustration-plate; do
  if [ -f "$SKILL_DIR/references/$w.tsx" ]; then
    # convert kebab-case to PascalCase for the destination filename
    pascal=$(echo "$w" | awk -F- '{ for(i=1;i<=NF;i++){ $i=toupper(substr($i,1,1)) substr($i,2) } print }' OFS='')
    cp "$SKILL_DIR/references/$w.tsx" "src/components/widgets/${pascal}.tsx"
  fi
done

# Create barrel export
cat > src/components/widgets/index.ts << 'BARREL'
// Reference widgets (Patterns 10–12 from the learn-by-play skill).
// Delete any you don't use; add your own here.
export { default as PlaybackWidget } from "./PlaybackWidget";
export type { PlaybackTrace, PlaybackStep } from "./PlaybackWidget";
export { default as ComplexityChart } from "./ComplexityChart";
export type { Curve, Complexity } from "./ComplexityChart";
export { default as IllustrationPlate, SketchFilterDefs, HeroPlate, DividerPlate, FooterMascot } from "./IllustrationPlate";
export type { Pin } from "./IllustrationPlate";
BARREL

# Create placeholder page
cat > src/app/page.tsx << 'PAGE'
"use client";

import { useEffect } from "react";

export default function Home() {
  useEffect(() => {
    const observer = new IntersectionObserver(
      (entries) => entries.forEach((e) => { if (e.isIntersecting) e.target.classList.add("visible"); }),
      { threshold: 0.1, rootMargin: "0px 0px -50px 0px" }
    );
    document.querySelectorAll(".reveal").forEach((el) => observer.observe(el));

    // Open any collapsed TOC <details> whose section is targeted by the hash
    const openTargetedDetails = () => {
      const id = window.location.hash.replace(/^#/, "");
      if (!id) return;
      const target = document.getElementById(id);
      if (!target) return;
      let el: HTMLElement | null = target;
      while (el) {
        if (el.tagName === "DETAILS") (el as HTMLDetailsElement).open = true;
        el = el.parentElement;
      }
    };
    openTargetedDetails();
    window.addEventListener("hashchange", openTargetedDetails);

    return () => {
      observer.disconnect();
      window.removeEventListener("hashchange", openTargetedDetails);
    };
  }, []);

  return (
    <main>
      {/* Navigation */}
      <nav className="sticky top-0 z-50 bg-background/85 backdrop-blur-xl border-b border-border px-4 md:px-6 py-3 flex items-center gap-4">
        <a href="#" className="flex items-center gap-2 font-bold text-foreground no-underline shrink-0">
          <div className="w-7 h-7 rounded-md bg-gradient-to-br from-orange-500 to-red-500 flex items-center justify-center font-extrabold text-white text-sm">
            ?
          </div>
          <span className="hidden md:inline text-sm font-semibold">Your Project</span>
        </a>
        <div className="flex gap-3 md:gap-4 overflow-x-auto whitespace-nowrap scrollbar-hide ml-auto">
          {/* Add section links here */}
        </div>
      </nav>

      {/* Hero */}
      <div className="relative overflow-hidden py-16 px-6 hero-gradient">
        <div className="hero-glow" />
        <div className="max-w-3xl mx-auto relative">
          <h1 className="text-3xl md:text-5xl font-extrabold leading-tight tracking-tight mb-4">
            Your Title Here
          </h1>
          <p className="text-lg text-muted-foreground max-w-xl">
            Your description here. Use colored terminology spans for key concepts.
          </p>
        </div>
      </div>

      {/* Content */}
      <div className="max-w-3xl mx-auto px-6 pb-24">
        {/* Add sections here following the pattern:
            <section id="concept" className="reveal">
              <h2>Concept Name</h2>
              <p>2-3 explanatory paragraphs</p>
              <YourWidget />
              <p>1-2 follow-up paragraphs</p>
            </section>
        */}
      </div>

      <footer className="border-t border-border py-8 px-6 text-center">
        <p className="text-muted-foreground text-sm">Built with the learn-by-play methodology.</p>
      </footer>
    </main>
  );
}
PAGE

# Configure static export
cat > next.config.ts << 'CONFIG'
import type { NextConfig } from "next";

const isProd = process.env.NODE_ENV === "production";

const repoName = process.env.REPO_NAME || "";

const nextConfig: NextConfig = {
  output: "export",
  ...(isProd && repoName ? { basePath: `/${repoName}`, assetPrefix: `/${repoName}/` } : {}),
  images: { unoptimized: true },
};

export default nextConfig;
CONFIG

# Add Google Fonts to layout
cat > src/app/layout.tsx << 'LAYOUT'
import type { Metadata } from "next";
import { Inter, JetBrains_Mono } from "next/font/google";
import { SketchFilterDefs } from "@/components/widgets";
import "./globals.css";

const inter = Inter({ subsets: ["latin"], variable: "--font-inter" });
const jetbrains = JetBrains_Mono({ subsets: ["latin"], variable: "--font-jetbrains" });

export const metadata: Metadata = {
  title: "Interactive Guide",
  description: "An interactive learn-by-play educational experience",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className={`${inter.variable} ${jetbrains.variable}`}>
      <body>
        <SketchFilterDefs />
        {children}
      </body>
    </html>
  );
}
LAYOUT

echo ""
echo "🎉 Project scaffolded successfully!"
echo ""
echo "Next steps:"
echo "  cd $PROJECT_NAME"
echo "  npm run dev"
echo ""
echo "Then start building widgets in src/components/widgets/"
echo "and adding sections to src/app/page.tsx"
