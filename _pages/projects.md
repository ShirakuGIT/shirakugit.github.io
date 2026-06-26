---
title: "Projects"
layout: gridlay
sitemap: false
permalink: /projects/
---

## Projects

<p class="projects-intro">Some projects I've built!</p>

<div class="projects-grid">
{% for project in site.data.projects %}
<div class="project-card">
<div class="project-media">
{% include project-media.html media=project.media caption=project.caption %}
</div>
<div class="project-body">
<div class="project-text">
<h3 class="project-title"><a href="{{ project.repo }}" target="_blank" rel="noopener">{{ project.name }}</a></h3>
<p class="project-subtitle">{{ project.subtitle }}</p>
<p class="project-description">{{ project.description }}</p>
</div>
<a class="project-github" href="{{ project.repo }}" target="_blank" rel="noopener" aria-label="View {{ project.name }} on GitHub"><i class="fa-brands fa-github"></i></a>
</div>
</div>
{% endfor %}
</div>
