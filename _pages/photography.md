---
title: "Photography"
layout: page
sitemap: false
permalink: /photography/
---

<p class="photo-intro">
Photos from places I've been and things I've seen. Click any image to view full-size.
</p>

{% if site.data.photography.size == 0 %}
<p><em>No photos yet — coming soon.</em></p>
{% else %}

{% assign photos = site.data.photography %}

{::nomarkdown}
<div class="photo-grid" id="photo-grid">
{% for p in photos %}
  {% assign thumb = p.thumb | default: p.src %}
  {% assign alt = p.alt | default: p.title %}
  <figure class="photo-item"
          data-src="{{ p.src }}"
          data-title="{{ p.title | escape }}"
          data-location="{{ p.location | escape }}"
          data-date="{{ p.date | date: '%b %-d, %Y' }}"
          data-camera="{{ p.camera | escape }}"
          data-lens="{{ p.lens | escape }}"
          data-exif="{{ p.exif | escape }}"
          data-pc="{{ p.pc | escape }}"
          data-index="{{ forloop.index0 }}">
    <img loading="lazy" src="{{ thumb }}" alt="{{ alt | escape }}">
    <figcaption class="photo-caption">
      <span class="photo-title">{{ p.title }}</span>
      {% if p.location %}<span class="photo-loc"><i class="fa-solid fa-location-dot"></i> {{ p.location }}</span>{% endif %}
    </figcaption>
  </figure>
{% endfor %}
</div>

<!-- Lightbox -->
<div class="photo-lightbox" id="photo-lightbox" aria-hidden="true" role="dialog">
  <button class="photo-close" id="photo-close" aria-label="Close">&times;</button>
  <button class="photo-nav photo-prev" id="photo-prev" aria-label="Previous">&larr;</button>
  <button class="photo-nav photo-next" id="photo-next" aria-label="Next">&rarr;</button>
  <div class="photo-stage">
    <img id="photo-full" alt="">
    <div class="photo-meta" id="photo-meta"></div>
  </div>
</div>

<script>
(function() {
  var items = Array.prototype.slice.call(document.querySelectorAll(".photo-item"));
  var lb    = document.getElementById("photo-lightbox");
  var img   = document.getElementById("photo-full");
  var meta  = document.getElementById("photo-meta");
  var prev  = document.getElementById("photo-prev");
  var next  = document.getElementById("photo-next");
  var close = document.getElementById("photo-close");
  var idx   = 0;

  function fmtMeta(d) {
    var bits = [];
    if (d.title)    bits.push('<div class="lb-title">' + d.title + '</div>');
    var line = [];
    if (d.location) line.push('<i class="fa-solid fa-location-dot"></i> ' + d.location);
    if (d.date)     line.push('<i class="fa-regular fa-calendar"></i> ' + d.date);
    if (line.length) bits.push('<div class="lb-sub">' + line.join(' &nbsp;·&nbsp; ') + '</div>');
    var tech = [];
    if (d.camera) tech.push(d.camera);
    if (d.lens)   tech.push(d.lens);
    if (d.exif)   tech.push(d.exif);
    if (tech.length) bits.push('<div class="lb-tech">' + tech.join(' &nbsp;·&nbsp; ') + '</div>');
    if (d.pc)     bits.push('<div class="lb-pc">PC: ' + d.pc + '</div>');
    return bits.join('');
  }
  function show(i) {
    if (i < 0) i = items.length - 1;
    if (i >= items.length) i = 0;
    idx = i;
    var el = items[idx];
    var d = el.dataset;
    img.src = d.src;
    img.alt = d.title || "";
    meta.innerHTML = fmtMeta(d);
  }
  function open(i) {
    show(i);
    lb.classList.add("open");
    lb.setAttribute("aria-hidden", "false");
    document.body.style.overflow = "hidden";
  }
  function shut() {
    lb.classList.remove("open");
    lb.setAttribute("aria-hidden", "true");
    document.body.style.overflow = "";
    img.src = "";
  }
  items.forEach(function(el) {
    el.addEventListener("click", function() { open(parseInt(el.dataset.index, 10)); });
  });
  prev.addEventListener("click", function(e) { e.stopPropagation(); show(idx - 1); });
  next.addEventListener("click", function(e) { e.stopPropagation(); show(idx + 1); });
  close.addEventListener("click", shut);
  lb.addEventListener("click", function(e) { if (e.target === lb) shut(); });
  document.addEventListener("keydown", function(e) {
    if (!lb.classList.contains("open")) return;
    if (e.key === "Escape")     shut();
    if (e.key === "ArrowLeft")  show(idx - 1);
    if (e.key === "ArrowRight") show(idx + 1);
  });
})();
</script>
{:/nomarkdown}

{% endif %}
