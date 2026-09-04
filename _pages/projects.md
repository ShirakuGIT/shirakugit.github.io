---
title: "Projects"
layout: gridlay
sitemap: false
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
    {%- when 3 -%}{%- assign cell = "bento-cell--wide" -%}
    {%- else -%}{%- assign cell = "bento-cell--pair" -%}
  {%- endcase -%}
<article class="bento-cell {{ cell }}">
<div class="bento-link" role="button" tabindex="0" aria-expanded="false" aria-label="{{ project.name }}{% if project.description %} — tap to show description{% endif %}">
<div class="bento-media">
{% include project-media.html media=project.media caption=project.caption %}
</div>
<div class="bento-shade"></div>
<div class="bento-head">
<a class="bento-chip" href="{{ project.repo }}" target="_blank" rel="noopener" aria-label="View {{ project.name }} on GitHub"><i class="fa-brands fa-github"></i> GitHub</a>
<a class="bento-arrow" href="{{ project.repo }}" target="_blank" rel="noopener" aria-label="View {{ project.name }} on GitHub" aria-hidden="true"><i class="fa-solid fa-arrow-up-right-from-square"></i></a>
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