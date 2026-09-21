// Shared formatting and notation for notes and homework.
#let concat = math.class("binary", sym.bullet)
#let eps = sym.epsilon

#let notes(body) = {
  set page(paper: "us-letter", margin: 1in, numbering: "1")
  set text(font: "Libertinus Serif", size: 11pt, lang: "en")
  set par(first-line-indent: 0pt, leading: 0.65em, spacing: 0.65em + 4pt)
  set list(spacing: 4pt)
  set enum(spacing: 4pt)
  body
}

#let homework(title: "", date: "", body) = {
  set document(title: title, author: "Anirudh Konidala")
  show: notes
  set heading(numbering: none)
  align(center)[
    #text(size: 17pt, weight: "bold", title)

    Anirudh Konidala \
    #date
  ]
  v(1em)
  body
}

#let theorem-counter = counter("theorem")
#let lemma-counter = counter("lemma")
#let theorem(body) = block[
  #theorem-counter.step()
  *Theorem #context theorem-counter.display().* #emph(body)
]
#let lemma(body) = block[
  #lemma-counter.step()
  *Lemma #context lemma-counter.display().* #emph(body)
]
