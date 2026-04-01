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

# Create barrel export
cat > src/components/widgets/index.ts << 'BARREL'
// Export your widgets here as you build them
// Example: export { MyWidget } from "./MyWidget";
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
    return () => observer.disconnect();
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

const nextConfig: NextConfig = {
  output: "export",
  basePath: isProd ? `/${process.env.REPO_NAME || ""}` : "",
  assetPrefix: isProd ? `/${process.env.REPO_NAME || ""}/` : "",
  images: { unoptimized: true },
};

export default nextConfig;
CONFIG

# Add Google Fonts to layout
cat > src/app/layout.tsx << 'LAYOUT'
import type { Metadata } from "next";
import { Inter, JetBrains_Mono } from "next/font/google";
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
      <body>{children}</body>
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
