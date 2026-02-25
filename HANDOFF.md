# Introduction to Quantum Computing — Handoff Document

## Status

Course material complete: 3 lectures + unified exercise sheet + full solutions.
Video material downloaded and transcribed.

## Source Material

- **Original notes**: 6 LaTeX files in `qc-trapped-ions-notes/` (3 lectures + 3 exercise sheets)
  from the course "Quantencomputing und Quantenlogik mit gespeicherten Ionen" (2022-2023)
- **Video**: "Quantum computing basics: What is quantum advantage?" by T.J. Osborne & Michael Walter
  - Downloaded to `video/` with 12 regular screenshots
  - Transcript in `transcripts/quantum_advantage_video.srt` (raw) and `transcripts/quantum_advantage_clean.txt` (cleaned)

## Content

### Lecture Notes (`latex/QuantumComputing.tex`)

| Lecture | File | Topic | Key additions from video |
|---------|------|-------|-------------------------|
| 1 | `lectures/lec01.tex` | Quantum circuits and the circuit model | Historical box on Feynman/Deutsch, Bloch sphere intuition, TikZ circuit diagrams, entanglement intuition, Solovay-Kitaev theorem |
| 2 | `lectures/lec02.tex` | Quantum algorithms (Deutsch-Jozsa, Grover) | Quantum advantage taxonomy (from video), phase kickback intuition, geometric Grover analysis with TikZ, BBBV optimality remark |
| 3 | `lectures/lec03.tex` | Trotterization and quantum simulation | Exponential wall intuition, higher-order formulas, advanced methods survey (QSVT, LCU, qDRIFT), Trotter error bound |

### Exercise Sheet (`latex/Exercises.tex`)

Single unified sheet with 14 exercises across three parts, no dates or deadlines.
Includes one computational exercise (Trotter error analysis in Julia).

### Solutions (`latex/solutions/Solutions.tex`)

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

- **12 screenshots** at 5-minute intervals in `video/screenshot_*.jpg`
- **Raw transcript**: `transcripts/quantum_advantage_video.srt` (26025 lines)
- **Clean transcript**: `transcripts/quantum_advantage_clean.txt`
- Video content enriched into lectures:
  - Bra-ket notation motivation → Lecture 1 context
  - Quantum advantage taxonomy → Lecture 2 intuition box
  - Query model & oracle motivation → Lecture 2 definitions
  - Deutsch's problem preview → Lecture 2 algorithm

## Future Work

- Interactive HTML visualizations (Bloch sphere, circuit simulator, Grover animation, Trotter convergence)
- Additional TikZ figures for all embedded images
- Web conversion pipeline (pandoc + MathJax, as in GR project)
- Additional lectures on: quantum error correction, variational algorithms, quantum phase estimation
