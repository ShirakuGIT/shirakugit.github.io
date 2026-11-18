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
    <span class="date">{{ post.date | date: "%Y-%m-%d" }}</span> <a class="post-link" href="{{ post.url | relative_url }}">{{ post.title }}</a>
  </li>
{%- endfor %}
</ul>
{:/nomarkdown}
