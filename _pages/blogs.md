---
title: "Blog"
layout: page
sitemap: false
permalink: /blogs/
---

{% if site.posts.size == 0 %}
<p><em>No posts yet — check back soon.</em></p>
{% endif %}

<div class="post-list">
{% for post in site.posts %}
<article class="post-card">
<h3 class="post-card-title"><a href="{{ site.url }}{{ site.baseurl }}{{ post.url }}">{{ post.title }}</a></h3>
<p class="post-card-meta"><i class="fa-regular fa-calendar"></i> {{ post.date | date: "%b %-d, %Y" }}{% if post.tags.size > 0 %} &nbsp;·&nbsp; {% for tag in post.tags %}<span class="post-tag">{{ tag }}</span>{% endfor %}{% endif %}</p>
<p class="post-card-excerpt">{{ post.excerpt | strip_html | truncatewords: 35 }}</p>
<a class="post-card-more" href="{{ site.url }}{{ site.baseurl }}{{ post.url }}">Read more →</a>
</article>
{% endfor %}
</div>
