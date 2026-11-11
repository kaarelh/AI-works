#!/usr/bin/env bash
# Rebuild tempered-learner.pdf: needs Node, npm access to install KaTeX, and Playwright's Chromium.
set -euo pipefail
cd -- "$(dirname -- "$0")"
npm install --no-audit --no-fund --silent
node build.mjs
