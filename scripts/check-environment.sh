#!/usr/bin/env bash

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$REPO_ROOT"

echo "Operating system: $(uname -s) $(sw_vers -productVersion 2>/dev/null || echo unknown)"
echo "Architecture: $(uname -m)"

if command -v git >/dev/null 2>&1; then
  echo "Git: $(command -v git)"
  git --version
else
  echo "Git: not found"
fi

if [[ -d "/Applications/Visual Studio Code.app" || -d "$HOME/Applications/Visual Studio Code.app" ]]; then
  echo "VS Code: installed"
else
  echo "VS Code: not found in the standard Applications locations (optional)"
fi

if command -v code >/dev/null 2>&1; then
  echo "code command: $(command -v code)"
  if code --list-extensions 2>/dev/null | grep -Fxqi "leanprover.lean4"; then
    echo "VS Code extension leanprover.lean4: installed"
  else
    echo "VS Code extension leanprover.lean4: not detected"
  fi
else
  echo "code command: not found (optional; install it from the VS Code Command Palette)"
  echo "VS Code extension leanprover.lean4: cannot query without the code command"
fi

if [[ -x "$HOME/.elan/bin/elan" ]]; then
  export PATH="$HOME/.elan/bin:$PATH"
fi

if command -v elan >/dev/null 2>&1; then
  echo "Elan: $(command -v elan)"
  elan --version
else
  echo "Elan: not found"
fi

if command -v lean >/dev/null 2>&1; then
  echo "Lean selected in this repository:"
  lean --version
else
  echo "Lean: not found"
fi

if command -v lake >/dev/null 2>&1; then
  echo "Lake selected in this repository:"
  lake --version
else
  echo "Lake: not found"
fi

if [[ -f lean-toolchain ]]; then
  echo "lean-toolchain: $(tr -d '\n' < lean-toolchain)"
else
  echo "lean-toolchain: missing"
fi

if [[ -f lake-manifest.json ]]; then
  echo "lake-manifest.json: present"
else
  echo "lake-manifest.json: missing"
fi

if command -v lake >/dev/null 2>&1 && [[ -f lean-toolchain ]] && [[ -f lake-manifest.json ]]; then
  echo "Running lake build..."
  if lake build; then
    echo "lake build: succeeded"
  else
    build_status=$?
    echo "lake build: failed (exit $build_status)"
    exit "$build_status"
  fi
else
  echo "lake build: not run because required tooling or project files are missing"
  exit 1
fi
