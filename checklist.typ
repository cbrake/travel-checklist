// Two-column packing checklist for one trip type, built from
// packing-list.ods. Run through checklist.sh, which exports the sheet to CSV
// and passes it in:
//   typst compile --input trip=Backpacking --input csv=<data> checklist.typ

#let trip-input = sys.inputs.at("trip", default: "Backpacking")
#let rows = csv(bytes(sys.inputs.at("csv")), row-type: dictionary)

// Match the trip column by case-insensitive prefix, so "car" finds "Car camping".
#let trip = rows.first().keys().slice(3).find(k => lower(k).starts-with(lower(trip-input)))
#if trip == none {
  panic("no trip column matches '" + trip-input + "'")
}

// Any non-empty cell (normally "x") marks the item for that trip.
#let items = rows.filter(r => r.at(trip).trim() != "")

#set page(paper: "us-letter", margin: 0.6in, columns: 2)
#set columns(gutter: 0.35in)
// Arial is not installed; Liberation Sans matches its letter widths and looks nearly the same.
#set text(font: "Liberation Sans", size: 10.5pt)
#show heading: set text(size: 11.5pt)
#show heading: set block(above: 1.1em, below: 0.55em)

#place(top + left, scope: "parent", float: true, clearance: 1em)[
  #text(size: 18pt, weight: "bold")[#trip packing list]
  #h(1fr)
  #text(fill: luma(100))[#items.len() items]
  #line(length: 100%, stroke: 0.5pt + luma(150))
]

#let box-mark = box(
  width: 0.8em,
  height: 0.8em,
  stroke: 0.6pt,
  radius: 1pt,
  baseline: 0.1em,
)

#for (category, group) in items.fold((), (acc, r) => {
  if acc.len() > 0 and acc.last().first() == r.Category {
    acc.last().last().push(r)
  } else {
    acc.push((r.Category, (r,)))
  }
  acc
}) [
  = #category
  #for r in group {
    block(below: 0.5em, breakable: false, grid(
      columns: (1.2em, 1fr),
      box-mark,
      [
        #r.Item
        #if r.Notes != "" [ \ #text(size: 8.5pt, fill: luma(90), r.Notes)]
      ],
    ))
  }
]

// Space to note what was missing, so the spreadsheet improves after each trip.
#block(above: 1.6em, breakable: false)[
  = Missed items
  #text(size: 8.5pt, fill: luma(90))[
    Write in anything you wished you had packed, then add it to the
    spreadsheet before the next trip.
  ]
  #for _ in range(8) {
    block(above: 1.5em, below: 0pt, grid(
      columns: (1.2em, 1fr),
      box-mark,
      line(start: (0pt, 0.75em), length: 100%, stroke: 0.4pt + luma(150)),
    ))
  }
]
