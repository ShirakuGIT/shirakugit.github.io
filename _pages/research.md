---
title: "Research"
layout: gridlay
description: "Research by Shivaram Kumar Jagannathan on spatial intelligence, visual priors, 3D reconstruction and task and motion planning for robots."
permalink: /research/
---

<style>
img{
  border-radius: 10px;
}
.col-md-3 {
  margin-top:10px;
  margin-bottom:10px;
  padding:0px;
  display:block;
  overflow:hidden;
  text-align:center;
  display: table-cell;
  background: white;
  border-radius: 20px;
  height: auto;
}
iframe {
  margin:0;
  padding:0;
  width: 175px;
  display: inline;
  vertical-align: middle;
}
</style>

## Research

<div class="jumbotron">

{% capture preprint_count %}{% bibliography_count --query @unpublished %}{% endcapture %}
{% if preprint_count != "0" %}
### Preprints
{% bibliography --query @unpublished %}
{% endif %}

{% capture article_count %}{% bibliography_count --query @article %}{% endcapture %}
{% if article_count != "0" %}
### Journal Articles
{% bibliography --query @article %}
{% endif %}

{% capture inproceedings_count %}{% bibliography_count --query @inproceedings %}{% endcapture %}
{% if inproceedings_count != "0" %}
### Conference Papers
{% bibliography --query @inproceedings %}
{% endif %}

</div>
