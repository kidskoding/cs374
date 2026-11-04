typst := env("TYPST", "typst")

# Course book, standalone lectures, homeworks, labs and problem sets
default: book lectures homeworks labs problem-sets

# Course book (cs374.pdf)
book:
    {{typst}} compile --root . cs374.typ cs374.pdf

# Standalone lecture PDFs in lectures/
lectures: (_build-all "lec[0-9]*.typ" "lectures")

# Local homework PDFs in homeworks/pdfs/
homeworks: (_build-all "homeworks/typst/*.typ" "homeworks/pdfs")

# Lab PDFs in labs/pdfs/
labs: (_build-all "labs/*.typ" "labs/pdfs")

# Problem-set PDFs in problem-sets/pdfs/
problem-sets: (_build-all "problem-sets/*.typ" "problem-sets/pdfs")

# One lecture, e.g. `just lecture lec19_10_29_26`
lecture name:
    @mkdir -p lectures
    {{typst}} compile --root . {{name}}.typ lectures/{{name}}.pdf

# One homework part, e.g. `just hw hw09p1`
hw name:
    @mkdir -p homeworks/pdfs
    {{typst}} compile --root . homeworks/typst/{{name}}.typ homeworks/pdfs/{{name}}.pdf

# Rebuild the book whenever an imported source changes
watch:
    {{typst}} watch --root . cs374.typ cs374.pdf

# shortcut: rebuilds every file each run (no make-style up-to-date checks); fine at this size.
_build-all pattern outdir:
    #!/usr/bin/env bash
    set -euo pipefail
    shopt -s nullglob
    mkdir -p {{outdir}}
    for f in {{pattern}}; do
        out="{{outdir}}/$(basename "${f%.typ}").pdf"
        echo "{{typst}} compile --root . $f $out"
        {{typst}} compile --root . "$f" "$out"
    done
