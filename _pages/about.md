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
    {% include social.html member=member size="2" %}
  </div>
</div>
{% endfor %}

<div class="logos-band">
<p class="logos-label">Experience</p>
{% include logos.html %}
</div>

<div class="prose">
<p class="about-lede">I'm a roboticist working at the intersection of classical planning and machine learning — building systems that perceive, plan, and act reliably in the real world.</p>

<p>At the <a href="https://algrobogroup.github.io/" target="_blank" rel="noopener">Algorithmic Robotics Group</a>, NTU, I work on general-purpose task &amp; motion planning for manipulation under <a href="https://yoonchangsung.com/" target="_blank" rel="noopener">Dr.&nbsp;Yoonchang Sung</a> — the Minimum Constraint Removal problem and learning-based priors that speed up planning in cluttered scenes. Before that I built multi-sensor fusion and SLAM pipelines for autonomous navigation, and perception/localization for industrial mobile robots robust to sensor failure.</p>

<h3>Selected work</h3>
<ul class="about-work">
<li><strong>Adaptive teleoperation for humanoid manipulation</strong> — ROS2 framework for full-body control via real-time pose tracking and multi-chain inverse kinematics.</li>
<li><strong>Vision-only quadcopter navigation</strong> — LQR + Kalman filtering for stable tracking to ≈±0.1&nbsp;m without IMU or odometry.</li>
<li><strong>Autonomous mobile manipulation</strong> — ROS2 nav stack + custom 6-DOF arm fusing LiDAR, RGB-D, and IMU with RL-based grasping.</li>
</ul>
</div>
