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

#let appendix(body) = {
  set heading(numbering: "A.1", supplement: [Appendix])
  show heading.where(level: 1): it => {
    set text(size: 1.4em, weight: "bold")
    block(above: 1.8em, below: 1em)[Appendix #counter(heading).display("A"): #it.body]
  }
  counter(heading).update(0)
  body
}

#let homework(title: "", date: "", body) = {
  set document(title: title, author: "Anirudh Konidala")
  show: notes
  set par(justify: true, spacing: 1.15em)
  set list(spacing: 0.95em)
  set enum(spacing: 0.95em)
  set heading(numbering: none)
  show heading: set text(size: 13pt)
  show heading: set block(above: 1.8em, below: 0.9em)
  align(center)[
    #text(size: 17pt, weight: "bold", title)

    #v(0.3em)
    Anirudh Konidala

    #v(0.1em)
    #date
  ]
  v(0.8em)
  body
}

// Framed display that sets off the main answer of a homework part.
#let boxed(body) = align(center, block(
  stroke: 0.5pt,
  inset: (x: 10pt, y: 7pt),
  above: 1em,
  below: 1em,
  body,
))

// Attribution lines required at the end of every homework part.
#let disclosures(sources: [None.], llm: []) = {
  [*Sources and collaborators:* #sources]
  parbreak()
  [*LLM use:* #llm]
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
