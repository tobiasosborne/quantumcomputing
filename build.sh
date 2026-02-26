#!/usr/bin/env bash
#
# build.sh — Build automation for Introduction to Quantum Computing
#
# Usage:
#   ./build.sh              Full build (3 passes + bibtex)
#   ./build.sh --draft      Single pass (fast)
#   ./build.sh --cmfonts    Computer Modern fonts (portable)
#   ./build.sh --simdata    Regenerate Julia simulation data only
#   ./build.sh --full       Regenerate data + build PDF
#   ./build.sh --clean      Remove generated files
#   ./build.sh --watch      Continuous build on file change
#   ./build.sh --exercises  Build exercise sheet
#   ./build.sh --solutions  Build solutions
#   ./build.sh --all        Build everything (notes + exercises + solutions)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LATEX_DIR="$SCRIPT_DIR/latex"
SCRIPTS_DIR="$SCRIPT_DIR/scripts"

# Default flags
CMFONTS=""
DRAFT=false

# ── Parse arguments ───────────────────────────────────────────
ACTION="${1:---build}"

case "$ACTION" in
  --draft)    DRAFT=true ;;
  --cmfonts)  CMFONTS="\\PassOptionsToPackage{cmfonts}{qc-style}" ;;
  --clean)
    echo "Cleaning generated files..."
    cd "$LATEX_DIR"
    rm -f *.aux *.log *.bbl *.blg *.out *.toc *.pdf
    rm -f lectures/*.aux
    rm -f solutions/*.aux solutions/*.log solutions/*.pdf
    echo "Done."
    exit 0
    ;;
  --simdata)
    echo "Regenerating Julia simulation data..."
    cd "$SCRIPTS_DIR"
    julia trotter_ising.jl
    echo "Done."
    exit 0
    ;;
  --full)
    echo "Regenerating data + building PDF..."
    cd "$SCRIPTS_DIR"
    julia trotter_ising.jl
    cd "$LATEX_DIR"
    exec "$0" --build
    ;;
  --watch)
    echo "Watching for changes... (Ctrl-C to stop)"
    cd "$LATEX_DIR"
    while true; do
      inotifywait -q -e modify -r . --include '\.tex$|\.sty$|\.bib$' 2>/dev/null
      echo "Change detected, rebuilding..."
      "$0" --draft || true
      echo "Waiting for next change..."
    done
    ;;
  --exercises)
    echo "Building exercise sheet..."
    cd "$LATEX_DIR"
    xelatex Exercises.tex
    echo "Done: Exercises.pdf"
    exit 0
    ;;
  --solutions)
    echo "Building solutions..."
    cd "$LATEX_DIR/solutions"
    xelatex Solutions.tex
    echo "Done: solutions/Solutions.pdf"
    exit 0
    ;;
  --all)
    "$0" --build
    "$0" --exercises
    "$0" --solutions
    exit 0
    ;;
  --build|*)
    ;;
esac

# ── Build main document ──────────────────────────────────────
cd "$LATEX_DIR"
echo "Building QuantumComputing.pdf..."

if $DRAFT; then
  echo "  [draft mode — single pass]"
  xelatex $CMFONTS QuantumComputing.tex
else
  echo "  [full mode — 3 passes + bibtex]"
  xelatex $CMFONTS QuantumComputing.tex
  bibtex QuantumComputing
  xelatex $CMFONTS QuantumComputing.tex
  xelatex $CMFONTS QuantumComputing.tex
fi

echo "Done: QuantumComputing.pdf"
