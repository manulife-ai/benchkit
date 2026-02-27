// This paper is written in Typst
// Install with `brew install typst`
// Edit and preview with the `Tynimist` VScode extension

#import "@preview/charged-ieee:0.1.3": ieee
#show: ieee.with(
  title: [A Typesetting System to Untangle the Scientific Writing Process],
  abstract: [
    #lorem(150)
  ],
  authors: ((
    name: "Romain Martinez",
    // department: [Co-Founder],
    organization: [Manulife Financial Corporation],
    location: [Montreal, Canada],
    email: "romain_martinez@manulife.ca",
  ), (
    name: "Sabya Mukherjee",
    // department: [Co-Founder],
    organization: [Manulife Financial Corporation],
    location: [Waterloo, Canada],
    email: "sabyasachi_mukherjee@manulife.ca",
  ),),
  index-terms: ("Scientific writing", "Typesetting", "Document creation", "Syntax"),
  bibliography: bibliography("refs.bib"),
  figure-supplement: [Fig.],
)

= Introduction
#lorem(200)

== Paper overview
#lorem(200)

= Methods <sec:methods>
#lorem(45)

$ a + b = gamma $ <eq:gamma>

#lorem(80)

#figure(placement: none, circle(radius: 15pt), caption: [A circle representing the Sun.]) <fig:sun>

In @fig:sun you can see a common representation of the Sun, which is a star that is located at the center of the solar
system.

#lorem(120)

#figure(caption: [The Planets of the Solar System and Their Average Distance from the Sun], placement: top, table(
  columns: (6em, auto),
  align: (left, right),
  inset: (x: 8pt, y: 4pt),
  stroke: (x, y) => if y <= 1 { (top: 0.5pt) },
  fill: (x, y) => if y > 0 and calc.rem(y, 2) == 0 { rgb("#efefef") },
  table.header[Planet][Distance (million km)],
  [Mercury],
  [57.9],
  [Venus],
  [108.2],
  [Earth],
  [149.6],
  [Mars],
  [227.9],
  [Jupiter],
  [778.6],
  [Saturn],
  [1,433.5],
  [Uranus],
  [2,872.5],
  [Neptune],
  [4,495.1],
)) <tab:planets>

In @tab:planets, you see the planets of the solar system and their average distance from the Sun. The distances were
calculated with @eq:gamma that we presented in @sec:methods.

#figure(image("../static/idp-overview.svg"), caption: [The IDP overview]) <fig:idp>