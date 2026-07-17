#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$REPO_ROOT"

if ! command -v git >/dev/null 2>&1; then
  echo "Error: Git is required. Install Apple's Command Line Tools with: xcode-select --install" >&2
  exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
  echo "Error: curl is required. It is included with macOS." >&2
  exit 1
fi

if command -v elan >/dev/null 2>&1; then
  echo "Elan found at: $(command -v elan)"
elif [[ -x "$HOME/.elan/bin/elan" ]]; then
  echo "Elan found at: $HOME/.elan/bin/elan (adding its directory to PATH for this run)"
  export PATH="$HOME/.elan/bin:$PATH"
else
  echo "Elan was not found; installing it with Lean's official noninteractive installer."
  curl -sSf https://elan.lean-lang.org/elan-init.sh | sh -s -- -y
  export PATH="$HOME/.elan/bin:$PATH"
fi

# The official installer normally configures future shells, but make its proxies
# available immediately and handle existing installations not yet on PATH.
export PATH="$HOME/.elan/bin:$PATH"

if command -v code >/dev/null 2>&1; then
  echo "VS Code command found at: $(command -v code)"
  echo "Installing or confirming the official Lean 4 extension..."
  code --install-extension leanprover.lean4
elif [[ -d "/Applications/Visual Studio Code.app" || -d "$HOME/Applications/Visual Studio Code.app" ]]; then
  echo "VS Code is installed, but the 'code' command is unavailable."
  echo "In VS Code, open the Command Palette and select: Shell Command: Install 'code' command in PATH"
  echo "Then install the official 'Lean 4' extension by Lean FRO."
else
  echo "VS Code is not installed. Command-line setup will continue."
  echo "Install it manually from https://code.visualstudio.com/ and install extension leanprover.lean4."
fi

if [[ ! -f lean-toolchain ]]; then
  echo "Error: committed project file lean-toolchain is missing." >&2
  exit 1
fi

if [[ ! -f lakefile.toml && ! -f lakefile.lean ]]; then
  echo "Error: committed Lake configuration is missing." >&2
  exit 1
fi

if [[ ! -f lake-manifest.json ]]; then
  echo "Error: committed lake-manifest.json is missing; refusing to update dependency pins implicitly." >&2
  exit 1
fi

echo "Tool versions selected for this repository:"
elan --version
lean --version
lake --version

echo "Downloading the precompiled mathlib cache using the committed dependency manifest..."
lake exe cache get

echo "Building Lean4Tutorial..."
lake build

echo "Success: lake build completed for $REPO_ROOT"
