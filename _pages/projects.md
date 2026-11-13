---
title: "Projects"
layout: gridlay
description: "Robotics projects by Shivaram Kumar Jagannathan, including 3D LiDAR SLAM, planning and perception, with demos and write-ups."
permalink: /projects/
body_class: projects-page
---

## Projects

<p class="projects-intro">Some projects I've built!</p>

<div class="bento-grid">
{::nomarkdown}
{% for project in site.data.projects %}
  {%- case forloop.index0 -%}
    {%- when 0 -%}{%- assign cell = "bento-cell--feature" -%}
    {%- when 1 -%}{%- assign cell = "bento-cell--pair" -%}
    {%- when 2 -%}{%- assign cell = "bento-cell--pair" -%}
    {%- when 3 -%}{%- assign cell = "bento-cell--lead" -%}
    {%- else -%}{%- assign cell = "bento-cell--pair" -%}
  {%- endcase -%}
<article class="bento-cell {{ cell }}">
<div class="bento-link" role="button" tabindex="0" aria-expanded="false" aria-label="{{ project.name }}{% if project.description %} — tap to show description{% endif %}">
<div class="bento-media">
{% include project-media.html media=project.media caption=project.caption %}
</div>
<div class="bento-shade"></div>
<div class="bento-head">
{%- if project.repo -%}
<a class="bento-chip" href="{{ project.repo }}" target="_blank" rel="noopener" aria-label="View {{ project.name }} on GitHub"><i class="fa-brands fa-github"></i> GitHub</a>
<a class="bento-arrow" href="{{ project.repo }}" target="_blank" rel="noopener" aria-label="View {{ project.name }} on GitHub" aria-hidden="true"><i class="fa-solid fa-arrow-up-right-from-square"></i></a>
{%- elsif project.video -%}
<a class="bento-chip" href="{{ project.video }}" target="_blank" rel="noopener" aria-label="Watch {{ project.name }} on YouTube"><i class="fa-brands fa-youtube"></i> YouTube</a>
<a class="bento-arrow" href="{{ project.video }}" target="_blank" rel="noopener" aria-label="Watch {{ project.name }} on YouTube" aria-hidden="true"><i class="fa-solid fa-arrow-up-right-from-square"></i></a>
{%- endif -%}
</div>
<div class="bento-body">
<span class="bento-kicker">{{ project.subtitle }}</span>
<span class="bento-title">{{ project.name }}</span>
<span class="bento-desc">{{ project.description }}</span>
</div>
</div>
</article>
{% endfor %}
{:/nomarkdown}
</div>

{::nomarkdown}
<script>
(function () {
  var cards = document.querySelectorAll(".bento-cell");

  // Square bento layout, seeded so it is the same on every load (change SEED to
  // get a different arrangement): shuffle the cards, then recursively cut a
  // 12x12 grid into one rectangle per card (random cuts, roughly proportional
  // to the card counts on each side), so the cards tile the square with no gaps.
  // Desktop only; CSS ignores the --col/--row variables below 981px. Without JS
  // the default server-rendered layout stays.
  var grid = document.querySelector(".bento-grid");
  if (grid && cards.length) {
    var SEED = 40;
    var rand = function () { // mulberry32
      SEED |= 0; SEED = SEED + 0x6D2B79F5 | 0;
      var t = Math.imul(SEED ^ SEED >>> 15, 1 | SEED);
      t = t + Math.imul(t ^ t >>> 7, 61 | t) ^ t;
      return ((t ^ t >>> 14) >>> 0) / 4294967296;
    };
    var list = Array.prototype.slice.call(cards);
    for (var i = list.length - 1; i > 0; i--) {
      var j = Math.floor(rand() * (i + 1));
      var tmp = list[i]; list[i] = list[j]; list[j] = tmp;
    }
    var N = 12, n = list.length;
    var m = n <= 16 ? 3 : 2; // minimum cell side, in grid units
    var cap = function (w, h) { return Math.floor(w / m) * Math.floor(h / m); };
    var rects = [];
    var cut = function (x, y, w, h, k) {
      if (k === 1) { rects.push([x, y, w, h]); return; }
      var opts = [];
      [true, false].forEach(function (vert) {
        var dim = vert ? w : h;
        for (var a = 1; a < k; a++) {
          for (var c = m; c <= dim - m; c++) {
            var A = vert ? cap(c, h) : cap(w, c), B = vert ? cap(w - c, h) : cap(w, h - c);
            if (A < a || B < k - a) continue;
            var d = (c / dim - a / k) * 1.5;
            opts.push([vert, a, c, Math.exp(-d * d)]);
          }
        }
      });
      if (!opts.length) { rects.push([x, y, w, h]); return; }
      var total = opts.reduce(function (s, o) { return s + o[3]; }, 0), r = rand() * total, o = opts[0];
      for (var q = 0; q < opts.length; q++) { r -= opts[q][3]; if (r <= 0) { o = opts[q]; break; } }
      if (o[0]) { cut(x, y, o[2], h, o[1]); cut(x + o[2], y, w - o[2], h, k - o[1]); }
      else { cut(x, y, w, o[2], o[1]); cut(x, y + o[2], w, h - o[2], k - o[1]); }
    };
    cut(0, 0, N, N, n);
    if (rects.length === n) {
      list.forEach(function (card, idx) {
        var r = rects[idx];
        card.style.setProperty("--col", (r[0] + 1) + " / span " + r[2]);
        card.style.setProperty("--row", (r[1] + 1) + " / span " + r[3]);
        card.classList.remove("bento-cell--feature", "bento-cell--lead", "bento-cell--pair", "bento-cell--wide");
        card.classList.add(r[2] * r[3] >= 48 ? "bento-cell--feature" : r[2] * r[3] >= 32 ? "bento-cell--lead" : "bento-cell--pair");
        grid.appendChild(card);
      });
      grid.classList.add("is-shuffled");
    }
  }
  cards.forEach(function (card) {
    var body = card.querySelector(".bento-link");
    if (!body) return;
    var toggle = function (force) {
      var open = (force !== undefined) ? force : !card.classList.contains("is-open");
      card.classList.toggle("is-open", open);
      body.setAttribute("aria-expanded", open ? "true" : "false");
    };
    body.addEventListener("click", function (e) {
      if (e.target.closest("a")) return;
      toggle();
    });
    body.addEventListener("keydown", function (e) {
      if (e.key === "Enter" || e.key === " ") {
        e.preventDefault();
        toggle();
      }
    });
  });
})();
</script>
{:/nomarkdown}