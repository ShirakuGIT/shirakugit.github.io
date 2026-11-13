---
title: "Projects"
layout: gridlay
description: "Robotics projects by Shivaram Kumar Jagannathan, including 3D LiDAR SLAM, planning and perception, with demos and write-ups."
permalink: /projects/
---

# Projects
{: .page-title}

Some projects I've built! Each one links to its code or video.
{: .page-intro}

{::nomarkdown}
<ul class="projects">
{%- for project in site.data.projects %}
  {%- assign _link = project.repo | default: project.video %}
  <li class="project" id="{{ project.name | slugify }}">
    <figure class="project-media">
      {%- if _link %}<a href="{{ _link }}">{% include project-media.html media=project.media caption=project.caption %}</a>{% else %}{% include project-media.html media=project.media caption=project.caption %}{% endif %}
      {%- if project.caption %}<figcaption>{{ project.caption }}</figcaption>{% endif %}
    </figure>
    <div class="project-text">
      <p class="project-name">{% if _link %}<a href="{{ _link }}">{{ project.name }}</a>{% else %}{{ project.name }}{% endif %}</p>
      {%- if project.subtitle %}<p class="project-sub">{{ project.subtitle }}</p>{% endif %}
      {%- if project.description %}<p>{{ project.description }}</p>{% endif %}
      <p class="bracket-links">
        {%- if project.repo %}<a href="{{ project.repo }}">code on GitHub</a>{% endif -%}
        {%- if project.video %}<a href="{{ project.video }}">video on YouTube</a>{% endif -%}
      </p>
    </div>
  </li>
{%- endfor %}
</ul>
{:/nomarkdown}
