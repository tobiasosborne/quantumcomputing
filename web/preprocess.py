#!/usr/bin/env python3
"""Preprocess QC lecture .tex files for Pandoc conversion.

Strategy: keep most LaTeX intact for pandoc's LaTeX reader.
Only handle things pandoc can't:
- TikZ pictures → placeholders
- Figures with \\input → placeholders
- \\eqbox → \\boxed
- Strip comments and TEX root directives
- Expand custom macros from qc-macros.sty
"""

import re
import sys


def preprocess(tex: str) -> str:
    # Strip TEX root directive
    tex = re.sub(r'%\s*!TEX root.*\n', '', tex)

    # Convert TikZ pictures to placeholders
    tex = re.sub(
        r'\\begin\{center\}\s*\\begin\{tikzpicture\}.*?\\end\{tikzpicture\}\s*\\end\{center\}',
        r'\n\n\\begin{center}\n\\textit{[TikZ diagram --- see PDF]}\n\\end{center}\n\n',
        tex, flags=re.DOTALL
    )
    tex = re.sub(
        r'\\begin\{tikzpicture\}.*?\\end\{tikzpicture\}',
        r'\\textit{[TikZ diagram --- see PDF]}',
        tex, flags=re.DOTALL
    )

    # Handle \begin{figure}...\end{figure}
    def figure_replacer(m):
        caption = ''
        cap_match = re.search(r'\\caption\{(.*?)\}', m.group(0), re.DOTALL)
        if cap_match:
            caption = cap_match.group(1)
            caption = re.sub(r'\\label\{[^}]*\}', '', caption).strip()
            caption = caption.replace('~', ' ')
        return f'\n\n\\textit{{[Figure: {caption}]}}\n\n'
    tex = re.sub(r'\\begin\{figure\}.*?\\end\{figure\}', figure_replacer, tex, flags=re.DOTALL)

    # Expand custom macros from qc-macros.sty
    nb = r'((?:[^{}]|\{(?:[^{}]|\{[^{}]*\})*\})*)'  # nested braces up to depth 2

    # Dirac notation
    tex = re.sub(r'\\ket\{' + nb + r'\}', lambda m: '|' + m.group(1) + '\\rangle', tex)
    tex = re.sub(r'\\bra\{' + nb + r'\}', lambda m: '\\langle ' + m.group(1) + '|', tex)
    tex = re.sub(r'\\braket\{' + nb + r'\}\{' + nb + r'\}',
                 lambda m: '\\langle ' + m.group(1) + '|' + m.group(2) + '\\rangle', tex)
    tex = re.sub(r'\\ketbra\{' + nb + r'\}\{' + nb + r'\}',
                 lambda m: '|' + m.group(1) + '\\rangle\\langle ' + m.group(2) + '|', tex)
    tex = re.sub(r'\\expect\{' + nb + r'\}', lambda m: '\\langle ' + m.group(1) + ' \\rangle', tex)

    # Common states
    tex = re.sub(r'\\kezero\b', '|0\\rangle', tex)
    tex = re.sub(r'\\keone\b', '|1\\rangle', tex)
    tex = re.sub(r'\\keplus\b', '|+\\rangle', tex)
    tex = re.sub(r'\\keminus\b', '|-\\rangle', tex)

    # Gate names - use \text{} which MathJax handles in math mode
    tex = re.sub(r'\\CNOT\b', r'\\text{CNOT}', tex)
    tex = re.sub(r'\\SWAP\b', r'\\text{SWAP}', tex)
    tex = re.sub(r'\\Toffoli\b', r'\\text{TOFFOLI}', tex)
    tex = re.sub(r'\\NOT\b', r'\\text{NOT}', tex)
    tex = re.sub(r'\\AND\b', r'\\text{AND}', tex)
    tex = re.sub(r'\\OR\b', r'\\text{OR}', tex)
    tex = re.sub(r'\\XOR\b', r'\\text{XOR}', tex)
    tex = re.sub(r'\\NAND\b', r'\\text{NAND}', tex)
    tex = re.sub(r'\\NOR\b', r'\\text{NOR}', tex)

    # Controlled gates
    tex = re.sub(r'\\CnU\{([^}]*)\}\{([^}]*)\}',
                 lambda m: 'C^{' + m.group(1) + '}(' + m.group(2) + ')', tex)
    tex = re.sub(r'\\CU\{([^}]*)\}', lambda m: 'C(' + m.group(1) + ')', tex)

    # Linear algebra
    tex = re.sub(r'\\tp\b', '\\\\otimes', tex)
    tex = re.sub(r'\\hilb\b', '\\\\mathcal{H}', tex)
    tex = re.sub(r'\\C\b', '\\\\mathbb{C}', tex)
    tex = re.sub(r'\\R\b', '\\\\mathbb{R}', tex)
    tex = re.sub(r'\\Z\b', '\\\\mathbb{Z}', tex)
    tex = re.sub(r'\\N\b', '\\\\mathbb{N}', tex)
    tex = re.sub(r'\\I\b', '\\\\mathbb{I}', tex)
    tex = re.sub(r'\\SU\{([^}]*)\}', lambda m: '\\text{SU}(' + m.group(1) + ')', tex)

    # Norm
    tex = re.sub(r'\\norm\{((?:[^{}]|\{[^{}]*\})*)\}',
                 lambda m: '\\lVert ' + m.group(1) + ' \\rVert', tex)

    # Operators
    tex = re.sub(r'\\bigO\{' + nb + r'\}', lambda m: 'O\\!\\left(' + m.group(1) + '\\right)', tex)
    tex = re.sub(r'\\comm\{([^}]*)\}\{([^}]*)\}',
                 lambda m: '[' + m.group(1) + ',\\,' + m.group(2) + ']', tex)
    tex = re.sub(r'\\Ox\b', 'O_x', tex)
    tex = re.sub(r'\\Oxpm\b', r'O_{x,\\pm}', tex)

    # Pauli matrices
    tex = re.sub(r'\\paulix\b', '\\\\sigma^x', tex)
    tex = re.sub(r'\\pauliy\b', '\\\\sigma^y', tex)
    tex = re.sub(r'\\pauliz\b', '\\\\sigma^z', tex)

    # Derivatives
    tex = re.sub(r'\\dd\b', '\\\\mathrm{d}', tex)
    tex = re.sub(r'\\pd\{([^}]*)\}\{([^}]*)\}',
                 lambda m: '\\frac{\\partial ' + m.group(1) + '}{\\partial ' + m.group(2) + '}', tex)
    tex = re.sub(r'\\td\{([^}]*)\}\{([^}]*)\}',
                 lambda m: '\\frac{d ' + m.group(1) + '}{d ' + m.group(2) + '}', tex)

    # Convert \textsc and \textsl in math to \text (MathJax-compatible)
    tex = re.sub(r'\\textsc\{([^}]*)\}', r'\\text{\\small \\1}', tex)
    tex = re.sub(r'\\textsl\{([^}]*)\}', r'\\text{\\1}', tex)

    # Convert \eqbox{...} to \boxed{...}
    tex = re.sub(r'\\eqbox\{([^}]+)\}', r'\\boxed{\1}', tex)

    # Strip formatting commands
    tex = tex.replace('\\leavevmode', '')
    tex = tex.replace('\\medskip', '\n')
    tex = tex.replace('\\bigskip', '\n')
    tex = tex.replace('\\smallskip', '\n')
    tex = tex.replace('\\noindent', '')
    tex = re.sub(r'\\figbox', '', tex)

    return tex


if __name__ == '__main__':
    text = sys.stdin.read()
    print(preprocess(text))
