---
title: "About"
layout: gridlay
description: "About Shivaram Kumar Jagannathan, a robotics researcher at the Algorithmic Robotics Group, NTU Singapore: background, affiliations and contact."
permalink: /about/
---

{% for member in site.data.pi %}
<div class="profile" markdown="0">
  <img class="portrait" src="{{ '/images/' | append: member.photo | relative_url }}" alt="{{ member.name }}" width="160" height="160"/>
  <h1 class="page-title">About</h1>
  <p class="profile-name"><b>{{ member.name }}</b><br><i>{{ member.info }}</i></p>
  {% include social.html member=member %}
</div>
{% endfor %}

<div class="prose" markdown="0">
<p class="about-lede">I'm a researcher working at the intersection of robotics and intelligence - classical robotics, spatial intelligence, machine learning, and real-world robot deployments.</p>

<p>At the <a href="https://algrobogroup.github.io/">Algorithmic Robotics Group</a>, NTU, I work under <a href="https://yoonchangsung.com/">Dr.&nbsp;Yoonchang Sung</a> on visual priors for robot decision-making, and 3D reconstruction for object search in cluttered scenes. Earlier, I worked extensively on perception and SLAM for industrial autonomous mobile robots.</p>
</div>

<h2 id="experience">Experience</h2>
{% include logos.html %}
