---
title: "About"
layout: gridlay
sitemap: false
permalink: /about/
---

{% for member in site.data.pi %}
<div class="profile-head" markdown="0">
  <img class="profile-pic profile-pic-lg" src="{{ site.url }}{{ site.baseurl }}/images/{{ member.photo }}" alt="{{ member.name }}"/>
  <div class="profile-meta">
    <h3 class="profile-name">{{ member.name }}</h3>
    <p class="profile-role">{{ member.info }}</p>
    {% include social.html member=member size="large" %}
  </div>
</div>
{% endfor %}

<div class="logos-band">
<p class="logos-label">Experience</p>
{% include logos.html %}
</div>

<div class="prose">
<p class="about-lede">I'm a researcher working at the intersection of robotics and intelligence - classical robotics, spatial intelligence, machine learning, and real-world robot deployments.</p>

<p>At the <a href="https://algrobogroup.github.io/" target="_blank" rel="noopener">Algorithmic Robotics Group</a>, NTU, I work under <a href="https://yoonchangsung.com/" target="_blank" rel="noopener">Dr.&nbsp;Yoonchang Sung</a> on visual priors for robot decision-making, and 3D reconstruction for object search in cluttered scenes. Earlier, I worked extensively on perception and SLAM for industrial autonomous mobile robots.</p>
</div>
