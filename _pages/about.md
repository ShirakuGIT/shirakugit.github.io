---

title: "About"
layout: gridlay
sitemap: false
permalink: /about/
---

## About

{% for member in site.data.pi %}

<div class="jumbotron">
<div class="row">
<div class="col-sm-4">
  <img src="{{ site.url }}{{ site.baseurl }}/images/{{ member.photo }}" width="100%" style="max-width:250px"/>
</div>
<div class="col-sm-8 col-xs-12">
  <h3>{{ member.name }}</h3>
  <h4><i>{{ member.info }}</i></h4>
  {% if member.email %}<a href="mailto:{{ member.email }}" target="_blank"><i class="fa fa-envelope-square fa-3x"></i></a>{% endif %}
  {% if member.cv %}<a href="{{ site.url }}{{ site.baseurl }}/{{ member.cv }}" target="_blank"><i class="ai ai-cv-square ai-3x"></i></a>{% endif %}
  {% if member.scholar %}<a href="{{ member.scholar }}" target="_blank"><i class="ai ai-google-scholar-square ai-3x"></i></a>{% endif %}
  {% if member.github %}<a href="{{ member.github }}" target="_blank"><i class="fa fa-github-square fa-3x"></i></a>{% endif %}
  {% if member.researchgate %}<a href="{{ member.researchgate }}" target="_blank"><i class="ai ai-researchgate-square ai-3x"></i></a>{% endif %}

  <ul style="overflow: hidden">
    {% for education in member.education %}
      <li>{{ education | replace: "-","&#8211;" }}</li>
    {% endfor %}
  </ul>

</div>
</div>
</div>

{% endfor %}

<div class="jumbotron">
<h3>Biography</h3>

<p>
I am an undergraduate student in Information Technology at the Manipal Institute of Technology, expected to graduate in 2026. My work focuses on robotics and autonomous systems, with an emphasis on motion planning, SLAM, sensor fusion, and machine learning methods for robotic perception and control.
</p>

<p>
I am currently a researcher with the Algorithmic Robotics Group at Nanyang Technological University in Singapore, where I work on general-purpose task and motion planning algorithms for robotic manipulation under the supervision of Dr. Yoonchang Sung. My research explores algorithmic approaches to constrained planning problems, including the Minimum Constraint Removal formulation, and investigates how learning-based priors such as graph neural networks can accelerate search and improve planning efficiency in complex environments.
</p>

<p>
Previously, I have worked on several robotics and autonomous systems projects across both research laboratories and industry. My work includes developing multi-sensor fusion pipelines for autonomous navigation, designing SLAM systems for mobile robots, and building robotic manipulation platforms using ROS2. I have also worked on perception and localization systems for industrial autonomous mobile robots, focusing on robust localization under sensor failure and noisy environments.
</p>

<p>
More broadly, I am interested in building reliable and scalable robotic systems that integrate classical robotics algorithms with modern machine learning techniques. My goal is to develop autonomous systems capable of robust perception, planning, and interaction in real-world environments.
</p>

</div>

<div class="jumbotron">
<h3>Research Interests</h3>
<ul>
<li>Task and Motion Planning</li>
<li>SLAM and Sensor Fusion</li>
<li>Machine Learning for Robotics</li>
<li>Reinforcement Learning</li>
<li>Embodied Learning</li>
<li>Perception</li>
</ul>
</div>

<div class="jumbotron">
<h3>Selected Projects</h3>
<ul>

<li>
<strong>Adaptive Teleoperation Middleware for Humanoid Manipulation</strong><br>
Developed a ROS2-based teleoperation framework enabling full-body humanoid control using real-time human pose tracking and inverse kinematics across multiple kinematic chains. The system supports multi-threaded execution with real-time trajectory control and visual monitoring.
</li>

<li>
<strong>Vision-Based Autonomous Quadcopter Navigation</strong><br>
Designed a vision-only autonomous flight system using LQR control and Kalman filtering for stable trajectory tracking. The system achieves approximately ±0.1 m positional accuracy without relying on IMU or odometry sensors.
</li>

<li>
<strong>Autonomous Mobile Manipulation Platform</strong><br>
Built a mobile manipulation system integrating the ROS2 navigation stack with a custom 6-DOF robotic arm. The system combines LiDAR, RGB-D, and IMU sensing with reinforcement learning-based grasping strategies.
</li>

</ul>
</div>
