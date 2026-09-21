# CS 374

UIUC CS 374 notes written in Typst. [Read the course book](cs374.pdf).

Install [Typst](https://typst.app/) (tested with 0.15.1) and GNU Make, then run:

```sh
make             # Course book, standalone lectures, and local homework PDFs
make watch       # Rebuild the book whenever an imported source changes
make lectures    # Standalone PDFs in lectures/
make homeworks   # Local homework PDFs in homeworks/pdfs/
```

You can also compile or watch individual documents directly, from this directory:

```sh
typst compile --root . cs374.typ cs374.pdf
typst watch --root . lec01.typ lectures/lec01.pdf
typst watch --root . homeworks/typst/hw03p2.typ homeworks/pdfs/hw03p2.pdf
```

`setup.typ` contains shared formatting, `concat` and `eps` notation, and
`theorem`/`lemma` helpers. For example: `$w concat eps = w$` or
`#theorem[Every finite language is regular.]` after importing the template.

Each lecture, lab, and problem set exports a `body` for the book and also compiles
on its own. To add a lecture, copy the structure of `lec01.typ`, then import and
place its body in `cs374.typ` before the appendix block. The Makefile discovers
new `lec*.typ` files automatically for standalone PDFs. Add labs and problem sets
to the book's appendix block in the desired order.

Homework sources live in `homeworks/typst/`, with SVG diagrams in
`homeworks/diagrams/`. The entire `homeworks/` directory remains Git-ignored.
Builds need only Typst; no LaTeX, Emacs, Pandoc, or downloaded Typst packages.
