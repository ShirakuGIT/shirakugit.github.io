---
title: "Research"
layout: gridlay
description: "Research by Shivaram Kumar Jagannathan on spatial intelligence, visual priors, 3D reconstruction and task and motion planning for robots."
permalink: /research/
---

# Research
{: .page-title}

{% capture preprint_count %}{% bibliography_count --query @unpublished %}{% endcapture %}
{% if preprint_count != "0" %}
## Preprints
{% bibliography --query @unpublished %}
{% endif %}

{% capture article_count %}{% bibliography_count --query @article %}{% endcapture %}
{% if article_count != "0" %}
## Journal Articles
{% bibliography --query @article %}
{% endif %}

{% capture inproceedings_count %}{% bibliography_count --query @inproceedings %}{% endcapture %}
{% if inproceedings_count != "0" %}
## Conference Papers
{% bibliography --query @inproceedings %}
{% endif %}
