---
title: "Notes"
layout: page
description: "A working garden of study notes, paper digests and tutorial implementations on robotics and machine learning."
permalink: /notes/
---

{% if site.notes.size == 0 %}
<p><em>No notes yet — coming soon.</em></p>
{% else %}

{% assign by_updated = site.notes | sort: "updated" | reverse %}
{% assign categories = by_updated | map: "category" | uniq | sort %}

{::nomarkdown}
<p class="category-index">
{%- for cat in categories %}
  {%- assign in_cat = by_updated | where: "category", cat %}
  <a href="#cat-{{ cat | slugify }}">{{ cat | capitalize }}</a>
{%- endfor %}
</p>

{%- for cat in categories %}
{%- assign in_cat = by_updated | where: "category", cat %}
<h2 id="cat-{{ cat | slugify }}">{{ cat | capitalize }}</h2>
<ul class="post-list">
  {%- for note in in_cat %}
  <li>
    {%- if note.updated %}<span class="date">{{ note.updated | date: "%Y-%m-%d" }}:</span> {% endif -%}
    <a class="post-link" href="{{ note.url | relative_url }}">{{ note.title }}</a>{% if note.status %} <span class="status">({{ note.status }})</span>{% endif %}
  </li>
  {%- endfor %}
</ul>
{%- endfor %}
{:/nomarkdown}

{% endif %}
