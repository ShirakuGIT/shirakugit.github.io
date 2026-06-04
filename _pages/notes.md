---
title: "Notes"
layout: page
sitemap: false
permalink: /notes/
---

<p class="notes-intro">
A working garden — book notes, paper digests, course study notes, tutorial implementations, and rough drafts. Categorized later. Use the tabs to filter.
</p>

{% if site.notes.size == 0 %}
<p><em>No notes yet — coming soon.</em></p>
{% else %}

{% assign by_updated = site.notes | sort: "updated" | reverse %}
{% assign categories = by_updated | map: "category" | uniq | sort %}

{::nomarkdown}
<div class="notes-filter" id="notes-filter">
  <button class="notes-filter-btn active" data-filter="all">All <span>({{ by_updated.size }})</span></button>
  {% for cat in categories %}
    {% assign in_cat = by_updated | where: "category", cat %}
    <button class="notes-filter-btn" data-filter="{{ cat }}">{{ cat | capitalize }} <span>({{ in_cat.size }})</span></button>
  {% endfor %}
</div>

<div class="notes-grid">
{% for note in by_updated %}
  {% assign cat = note.category | default: "misc" %}
  <article class="note-card" data-category="{{ cat }}">
    <div class="note-card-head">
      <span class="note-category note-category-{{ cat }}">{{ cat | capitalize }}</span>
      {% if note.status %}<span class="note-status note-status-{{ note.status }}">{{ note.status | upcase }}</span>{% endif %}
    </div>
    <h3 class="note-card-title"><a href="{{ site.url }}{{ site.baseurl }}{{ note.url }}">{{ note.title }}</a></h3>
    {% if note.summary %}<p class="note-card-summary">{{ note.summary }}</p>{% endif %}
    <p class="note-card-meta">
      {% if note.updated %}<i class="fa-regular fa-clock"></i> {{ note.updated | date: "%b %-d, %Y" }}{% endif %}
      {% if note.tags.size > 0 %} &nbsp;·&nbsp; {% for tag in note.tags %}<span class="post-tag">{{ tag }}</span>{% endfor %}{% endif %}
    </p>
  </article>
{% endfor %}
</div>

<script>
(function() {
  var btns = document.querySelectorAll(".notes-filter-btn");
  var cards = document.querySelectorAll(".note-card");
  btns.forEach(function(b) {
    b.addEventListener("click", function() {
      var f = b.getAttribute("data-filter");
      btns.forEach(function(x) { x.classList.remove("active"); });
      b.classList.add("active");
      cards.forEach(function(c) {
        c.style.display = (f === "all" || c.getAttribute("data-category") === f) ? "" : "none";
      });
    });
  });
})();
</script>
{:/nomarkdown}

{% endif %}
