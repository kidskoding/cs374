// Shared formatting and notation for notes and homework.
#let concat = math.class("binary", sym.bullet)
#let eps = sym.epsilon

// Literal alphabet symbols in regular expressions and languages (red monospace, as in the labs).
#let lit(s) = text(fill: rgb("#c0392b"), font: "DejaVu Sans Mono", size: 0.9em, s)
#let hrule = block(above: 1em, below: 1em, line(length: 100%, stroke: 0.5pt))
#let lits(..xs) = xs.pos().map(lit).join(", ")

// Recursion tree drawn level by level. Each level is (label, node values, level sum).
#let recursion-tree(..levels) = align(center, block(width: 90%, breakable: false, grid(
  columns: (auto, 1fr, auto),
  column-gutter: 1em,
  row-gutter: 0.9em,
  [*Level*], align(center)[*Nodes*], [*Sum*],
  ..levels.pos().map(((label, nodes, sum)) => (
    align(left, label),
    align(center, nodes.map(v => box(stroke: 0.5pt, inset: (x: 4pt, y: 3pt), v)).join(h(6pt))),
    align(right, sum),
  )).flatten(),
)))

#let notes(body) = {
  set page(paper: "us-letter", margin: 1in, numbering: "1")
  set text(font: "New Computer Modern", size: 11pt, lang: "en")
  show heading: set block(above: 1.6em, below: 0.9em)
  set par(first-line-indent: 0pt, justify: true, leading: 0.8em, spacing: 1.4em)
  set list(spacing: 1.2em)
  set enum(spacing: 1.2em)
  set math.cases(gap: 0.6em)
  show math.equation.where(block: true): set block(above: 1.6em, below: 1.6em)
  show table: it => block(breakable: false, it)
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

// Pseudocode in the style of the course handouts: small-caps procedure names, red
// ⟨⟨comments⟩⟩, and a framed box with an underlined header. Each row is
// (indent level, line) or (indent level, line, comment).
#let fn(name) = smallcaps(name)
#let cmt(body) = text(fill: rgb("#c0392b"), style: "italic")[⟨⟨#body⟩⟩]
#let algo(header, ..rows) = align(center, block(
  breakable: false,
  stroke: 0.5pt,
  inset: (x: 12pt, y: 8pt),
  above: 1em,
  below: 1em,
  align(left, grid(
    columns: (auto, auto),
    column-gutter: 2em,
    row-gutter: 0.7em,
    grid.cell(colspan: 2, underline(offset: 2pt, header)),
    ..rows.pos().map(r => {
      let (level, line, ..comment) = r
      let body = pad(left: level * 1.3em, line)
      if comment.len() > 0 { (body, cmt(comment.at(0))) } else { (grid.cell(colspan: 2, body),) }
    }).flatten(),
  )),
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

// ---------------------------------------------------------------------------
// Visual helpers for lecture notes: callouts, arrays, flow charts, diagrams.

#let accent = rgb("#2e6da4")
#let accent-light = rgb("#eaf2fb")
#let warn-color = rgb("#c0392b")
#let warn-light = rgb("#fdecea")
#let mark-color = rgb("#f7dc6f")

#let callout(title, color, fill, body) = block(
  width: 100%,
  fill: fill,
  stroke: (left: 3pt + color),
  inset: (x: 10pt, y: 8pt),
  radius: (right: 3pt),
  above: 1.2em,
  below: 1.2em,
  [#text(fill: color, weight: "bold", title)#h(0.6em)#body],
)
#let keyidea(body) = callout([Key idea], accent, accent-light, body)
#let trap(body) = callout([Watch out], warn-color, warn-light, body)

// Row of array cells; `hl` lists 0-based indices to highlight.
#let cells(..xs, hl: (), fill: white) = box(grid(
  columns: (1.7em,) * xs.pos().len(),
  rows: 1.5em,
  stroke: 0.6pt,
  align: center + horizon,
  fill: (x, y) => if x in hl { mark-color } else { fill },
  ..xs.pos().map(v => [#v]),
))

// Boxes joined by right arrows, for "this turns into that" pipelines.
#let flow(..steps) = align(center, grid(
  columns: steps.pos().len() * 2 - 1,
  column-gutter: 6pt,
  align: center + horizon,
  ..steps.pos().map(s => box(
    stroke: 0.6pt + accent,
    fill: accent-light,
    inset: (x: 7pt, y: 6pt),
    radius: 3pt,
    text(size: 0.9em, s),
  )).intersperse(text(fill: accent, sym.arrow.r)),
))

// Tower of Hanoi snapshot. `pegs` holds three arrays of disk sizes (1..n), bottom first.
#let hanoi(pegs, n: 4, caption: none) = {
  let pw = 52pt
  let dh = 7pt
  let h = (n + 1.5) * dh
  let picture = box(width: 3 * pw, height: h, {
    place(dy: h, line(length: 3 * pw, stroke: 1.2pt))
    for (i, peg) in pegs.enumerate() {
      let cx = pw * (i + 0.5)
      place(dx: cx - 1pt, rect(width: 2pt, height: h, fill: luma(140), stroke: none))
      for (j, d) in peg.enumerate() {
        let w = 12pt + (d - 1) * (pw - 18pt) / calc.max(n - 1, 1)
        place(dx: cx - w / 2, dy: h - (j + 1) * dh, rect(
          width: w,
          height: dh - 1pt,
          radius: 2pt,
          stroke: 0.4pt,
          fill: if d == n { accent } else { accent-light },
        ))
      }
    }
  })
  let pegnames = grid(columns: (pw,) * 3, align: center, ..("src", "tmp", "dst").map(t => text(size: 0.75em, raw(t))))
  align(center, stack(spacing: 4pt, picture, pegnames, if caption != none { text(size: 0.85em, caption) }))
}

// Drawn recursion tree. Level i is an array of node labels laid out evenly; a level with
// k times as many nodes as the one above gets k edges per parent. Levels listed in `cut`
// get no edges into them, and levels in `plain` are drawn without node boxes (for dots).
#let tree-diagram(
  levels,
  labels: none,
  sums: none,
  cut: (),
  plain: (),
  width: 300pt,
  row: 30pt,
  node-w: 30pt,
  node-h: 15pt,
) = {
  let lw = if labels == none { 0pt } else { 42pt }
  let sw = if sums == none { 0pt } else { 70pt }
  let top = 18pt
  let pos(i, j) = (lw + width * (j + 0.5) / levels.at(i).len(), top + row * i + node-h / 2)
  let total-h = top + row * (levels.len() - 1) + node-h
  align(center, block(breakable: false, box(width: lw + width + sw, height: total-h, {
    if labels != none { place(dx: 0pt, text(size: 0.8em, weight: "bold")[Level]) }
    if sums != none { place(dx: lw + width, box(width: sw, align(right, text(size: 0.8em, weight: "bold")[Level sum]))) }
    for i in range(1, levels.len()) {
      let above = levels.at(i - 1).len()
      let here = levels.at(i).len()
      if i not in cut and here >= above and calc.rem(here, above) == 0 {
        let k = calc.quo(here, above)
        for j in range(here) {
          let (px, py) = pos(i - 1, calc.quo(j, k))
          let (cx, cy) = pos(i, j)
          place(line(start: (px, py + node-h / 2), end: (cx, cy - node-h / 2), stroke: 0.5pt + luma(130)))
        }
      }
    }
    for (i, level) in levels.enumerate() {
      for (j, label) in level.enumerate() {
        let (x, y) = pos(i, j)
        place(dx: x - node-w / 2, dy: y - node-h / 2, box(
          width: node-w,
          height: node-h,
          radius: 2pt,
          fill: if i in plain { none } else { accent-light },
          stroke: if i in plain { none } else { 0.5pt + accent },
          align(center + horizon, text(size: 0.75em, label)),
        ))
      }
      let (_, y) = pos(i, 0)
      if labels != none {
        place(dy: y - node-h / 2, box(height: node-h, align(horizon, text(size: 0.85em, labels.at(i)))))
      }
      if sums != none {
        place(dx: lw + width, dy: y - node-h / 2, box(width: sw, height: node-h, align(right + horizon, text(size: 0.85em, sums.at(i)))))
      }
    }
  })))
}

// Level sums as centered bars, top level first, so the shape of the series is visible.
#let level-bars(title, values, color: accent, caption: none) = align(center, stack(
  spacing: 5pt,
  text(size: 0.85em, weight: "bold", title),
  ..values.map(v => box(width: v * 80pt, height: 7pt, fill: color, radius: 1pt)),
  if caption != none { text(size: 0.8em, caption) },
))
