# Introduction to Quantum Computing — Handoff Document

## Status

Course material complete: 3 lectures + unified exercise sheet + full solutions (local only).
Video material downloaded and transcribed.
GitHub Pages website live with interactive visualizations.
Solutions removed from repository (gitignored, kept locally).

- **GitHub repo**: https://github.com/tobiasosborne/quantumcomputing
- **GitHub Pages**: https://tobiasosborne.github.io/quantumcomputing/

## Source Material

- **Original notes**: 6 LaTeX files in `qc-trapped-ions-notes/` (3 lectures + 3 exercise sheets)
  from the course "Quantencomputing und Quantenlogik mit gespeicherten Ionen" (2022-2023)
- **Video**: "Quantum computing basics: What is quantum advantage?" by T.J. Osborne & Michael Walter
  - Downloaded to `video/` (gitignored, ~518 MB) with 12 regular screenshots
  - Transcript in `transcripts/quantum_advantage_video.srt` (raw) and `transcripts/quantum_advantage_clean.txt` (cleaned)

## Content

### Lecture Notes (`latex/QuantumComputing.tex`, 17 pages)

| Lecture | File | Topic | Key additions from video |
|---------|------|-------|-------------------------|
| 1 | `lectures/lec01.tex` | Quantum circuits and the circuit model | Historical box on Feynman/Deutsch, Bloch sphere intuition, TikZ circuit diagrams, entanglement intuition, Solovay-Kitaev theorem, no-cloning remark, {H,T,CNOT} discrete universal set, expanded two-level decomposition with Givens rotations, worked examples (cyclic permutation decomposition, SWAP via Gray codes with circuit diagram) |
| 2 | `lectures/lec02.tex` | Quantum algorithms (Deutsch-Jozsa, Grover) | Quantum advantage taxonomy (from video), phase kickback intuition, geometric Grover analysis with TikZ, BBBV optimality remark |
| 3 | `lectures/lec03.tex` | Trotterization and quantum simulation | Exponential wall intuition, higher-order formulas, advanced methods survey (QSVT, LCU, qDRIFT), Trotter error bound with proof sketch, expanded Lie-Trotter proof (telescoping identity), expanded commuting case proof (ODE uniqueness), symmetrization intuition for Suzuki-Trotter, recursive higher-order formula |

### Exercise Sheet (`latex/Exercises.tex`, 2 pages)

Single unified sheet with 14 exercises across three parts, no dates or deadlines.
Includes one computational exercise (Trotter error analysis in Julia).

### Solutions (`latex/solutions/Solutions.tex`, 7 pages) — **local only, gitignored**

Complete model solutions for all exercises including:
- Truth tables and circuit diagrams
- Step-by-step Grover's algorithm execution
- Proof of the commuting Hamiltonian characterization
- Julia code for Trotter error analysis

### Julia Scripts (`scripts/`)

| Script | Purpose |
|--------|---------|
| `trotter_ising.jl` | Trotter error analysis for 4-qubit Ising model |
| `grover_demo.jl` | Step-by-step Grover's algorithm demonstration |

## GitHub Pages Website (`docs/`)

All lectures converted to HTML via pandoc with custom Lua filter and MathJax.
Solutions are **not** included on the website.

### Lecture Pages

| Page | Source | Content |
|------|--------|---------|
| `lec01.html` | `lectures/lec01.tex` | Quantum circuits — foldable intuition/historical boxes, MathJax equations |
| `lec02.html` | `lectures/lec02.tex` | Quantum algorithms — Deutsch-Jozsa, Grover's algorithm |
| `lec03.html` | `lectures/lec03.tex` | Quantum simulation — Lie-Trotter, Trotterization |

### Interactive Visualizations

| Page | Description |
|------|-------------|
| `bloch-sphere.html` | 3D draggable Bloch sphere with gate buttons (X, Y, Z, H, S, T), smooth animation, preset states, Bloch vector coordinates |
| `grover-visualizer.html` | Geometric view of Grover's algorithm in the |G⟩/|B⟩ plane; step-by-step reflections, probability plot, auto-run, configurable N and t |
| `solovay-kitaev.html` | Recursive gate compilation on SU(2) based on Dawson-Nielsen (arXiv:quant-ph/0505030); adaptive zoom follows convergence, log-scale error plot, group commutator decomposition display |

### Web Conversion Pipeline (`web/`)

| File | Role |
|------|------|
| `preprocess.py` | Expands QC macros (Dirac notation, gate names, etc.) for pandoc |
| `qc-filter.lua` | Pandoc Lua filter mapping custom LaTeX environments to styled HTML (foldable details/summary for intuition, historical, keyresult, algorithmbox; styled divs for definition, theorem, exercise, remark) |
| `template.html` | MathJax 3 + CSS template with nav bar, fold/unfold controls, responsive layout |

To regenerate HTML from LaTeX:
```bash
python3 web/preprocess.py < latex/lectures/lec01.tex | \
  pandoc -f latex -t html --lua-filter=web/qc-filter.lua \
  --template=web/template.html --metadata title="Quantum Circuits" \
  -o docs/lec01.html
```

## Architecture

Follows the same three-tier style system as the General Relativity project:

| File | Role |
|------|------|
| `qc-style.sty` | Geometry, colors, fonts, theorem environments, tcolorbox environments |
| `qc-macros.sty` | Dirac notation, gate names, linear algebra, TikZ circuit styles |
| `qc-tikz-templates.sty` | pgfplots styles, circuit drawing macros, Bloch sphere template |

### Color Palette (inherited from GR project)

- **spacecadet** (#0D284C): body text, dark elements
- **cgblue** (#007CA5): headings, definitions, links
- **munsell** (#008FA8): intuition boxes
- **banana** (#FFD932): key equation highlights
- **isabelline** (#EAEDEA): backgrounds, figure placeholders

### Custom Environments

- `keyresult[title]` — banana-highlighted important results
- `intuition[title]` — teal-framed physical insight boxes
- `historical[title]` — gray historical context boxes
- `algorithmbox[title]` — blue-framed algorithm descriptions
- `solution` — proof-style solution environment

## Build

```bash
./build.sh              # Full build (3 passes + bibtex)
./build.sh --draft      # Single pass
./build.sh --cmfonts    # Computer Modern fallback
./build.sh --exercises  # Build exercise sheet only
./build.sh --solutions  # Build solutions only
./build.sh --all        # Build everything
./build.sh --simdata    # Regenerate Julia data
./build.sh --clean      # Remove generated files
./build.sh --watch      # Continuous rebuild on change
```

**Engine**: xelatex (required for mathspec/fontspec)
**Fonts**: Times LT Std + Whitney (with `--cmfonts` fallback)

## Video Material

- **Video file**: `video/` (gitignored, ~518 MB webm)
- **12 screenshots** at 5-minute intervals in `video/screenshot_*.jpg`
- **Raw transcript**: `transcripts/quantum_advantage_video.srt` (26025 lines)
- **Clean transcript**: `transcripts/quantum_advantage_clean.txt`
- Video content enriched into lectures:
  - Bra-ket notation motivation → Lecture 1 context
  - Quantum advantage taxonomy → Lecture 2 intuition box
  - Query model & oracle motivation → Lecture 2 definitions
  - Deutsch's problem preview → Lecture 2 algorithm

## Recent Changes

- Solutions removed from GitHub repository (gitignored) to prevent student copying
- Lecture notes reviewed, errors fixed, proofs expanded (14 → 17 pages):
  - **Lec 1**: Added no-cloning theorem, identified {H,T,CNOT} as discrete universal set, expanded two-level decomposition with explicit Givens rotation formula, expanded Gray code circuit construction, added worked examples (3×3 cyclic permutation decomposition, SWAP gate via Gray codes with circuit diagram)
  - **Lec 2**: Fixed HHL year inconsistency (2008 → 2009)
  - **Lec 3**: Fixed gate count error (2^{2^n} → 4^n), expanded commuting Hamiltonian proof (ODE uniqueness argument), filled gap in Lie-Trotter proof (telescoping identity), added Trotter error bound proof sketch, defined h_max notation, added symmetrization intuition for second-order Suzuki-Trotter, added recursive higher-order Suzuki formula

## Future Work

- ~~Additional TikZ figures to replace `[TikZ diagram — see PDF]` placeholders in HTML~~ ✓ All 8 TikZ placeholders replaced with inline SVG diagrams
- Regenerate HTML pages from updated LaTeX (proofs have been expanded)
- Trotter convergence interactive visualization
- Quantum circuit builder/simulator visualization
- Additional lectures on: quantum error correction, variational algorithms, quantum phase estimation
- Full web conversion of exercise sheet (without solutions)
