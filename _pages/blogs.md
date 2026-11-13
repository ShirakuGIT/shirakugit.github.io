---
title: "Blog"
layout: page
description: "Essays and blog posts on robotics, intelligence and research ideas by Shivaram Kumar Jagannathan."
permalink: /blogs/
---

{% if site.posts.size == 0 %}
<p><em>No posts yet — check back soon.</em></p>
{% endif %}

{::nomarkdown}
<ul class="post-list">
{%- for post in site.posts %}
  <li>
    <span class="date">{{ post.date | date: "%Y-%m-%d" }}:</span> <a class="post-link" href="{{ post.url | relative_url }}">{{ post.title }}</a>
    <br><span class="meta">{{ post.content | strip_html | number_of_words | divided_by: 200 | at_least: 1 }} min read{% if post.tags.size > 0 %} · {{ post.tags | join: ", " }}{% endif %}</span>
    <p class="excerpt">{{ post.excerpt | strip_html | truncatewords: 35 }} <a href="{{ post.url | relative_url }}">Read more →</a></p>
  </li>
{%- endfor %}
</ul>
{:/nomarkdown}
<p class="small">Also available as an <a href="{{ '/feed.xml' | relative_url }}">RSS feed</a>. Shorter, rougher writing lives in the <a href="{{ '/notes/' | relative_url }}">notes</a>.</p>
