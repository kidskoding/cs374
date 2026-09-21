# Typst migration

Approved scope: replace all Org sources, including ignored homework sources, with
native Typst; preserve prose, mathematics, PDF paths, and book appendices.

- [x] Convert the lecture, lab, problem set, and six homework documents. Share
  page/text styling in `setup.typ`; export note bodies for the combined book.
  Replace the two TikZ diagrams with SVG assets containing the same transitions.
- [x] Replace the book entry point with `cs374.typ`; add a Makefile for the book,
  standalone lectures, homework PDFs, and watch mode. Update README and Git
  attributes; remove obsolete Org sources and editor configuration after checks.
- [x] Compile all documents with Typst, compare source content and math counts,
  inspect rendered pages for clipping and diagram correctness, and confirm that
  the Git index is unchanged. No new commits or staging are part of this task.

Validation uses compilation, content comparison, and visual inspection rather
than implementation-mirroring unit tests. Keep a temporary snapshot of original
sources/PDFs outside the repository until migration verification is complete.

Verified: all eight PDF targets rebuilt with Typst 0.15.1; standalone lab and
problem set and notation helpers compile; prose order, equation counts, and
explicit page breaks match the original sources. Inspected book and homework
renders, including both state diagrams. Original Git index preserved.
