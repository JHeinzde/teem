#!/usr/bin/env bash
# Serve the power-trace analysis API docs locally with pdoc.
# Reads docstrings directly from the source — no separate doc files to maintain.
#
# Usage:
#   ./serve_docs.sh            # live browser view at http://localhost:8080
#   ./serve_docs.sh --build    # write static HTML to doc/api/ instead
set -euo pipefail
cd "$(dirname "$0")"

PYTHON="${PYTHON:-.venv/bin/python}"
MODULES=(src.power)

if ! "$PYTHON" -c "import pdoc" 2>/dev/null; then
    echo "pdoc is not installed. Install it with:"
    echo "  $PYTHON -m pip install pdoc"
    exit 1
fi

if [[ "${1:-}" == "--build" ]]; then
    "$PYTHON" -m pdoc -d google -o doc/api "${MODULES[@]}"
    echo "Static docs written to doc/api/ — open doc/api/index.html"
else
    "$PYTHON" -m pdoc -d google "${MODULES[@]}"
fi
