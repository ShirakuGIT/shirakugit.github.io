---
layout: post
title: "Welcome to the Blog"
date: 2026-06-01
author: Shivaram Kumar Jagannathan
tags: [meta, robotics]
---

This is a sample post showing everything the blog supports. Delete it once you
publish your own. To start a new post, run `./new-post.sh "My Title" tag1 tag2`.

## Math (LaTeX)

Inline math like $\nabla \cdot \mathbf{B} = 0$ works, and so do display blocks:

$$
\hat{x}_{k} = \hat{x}_{k}^{-} + K_k \left( z_k - H \hat{x}_{k}^{-} \right)
$$

That's the Kalman filter measurement update — handy for sensor fusion.

## Images

{% include figure.html src="/images/feynman.jpg" caption="An image with a caption. Use width to constrain it." width="70%" %}

## Video

Embed YouTube, Vimeo, or a hosted `.mp4`:

{% include video.html youtube="aircAruvnKk" caption="Drop in any YouTube ID." %}

## GIFs

Use a `.gif`, or — lighter and smoother — a silent looping `.mp4`:

```liquid
{% raw %}{% include gif.html src="/images/demo.gif" caption="A looping demo." %}
{% include gif.html mp4="/images/demo.mp4" caption="Same, but as mp4." %}{% endraw %}
```

## Code

```python
def fuse(imu, lidar):
    return kalman_update(imu, lidar)
```

Everything above is plain Markdown plus the `figure` / `video` / `gif` includes.

## Jupyter notebooks

Drop a `.ipynb` anywhere under `assets/notebooks/` and embed it inline:

```liquid
{% raw %}{% jupyter_notebook "/assets/notebooks/demo.ipynb" %}{% endraw %}
```

Renders at build time — markdown cells, syntax-highlighted code, stdout, errors, plots (PNG/SVG), HTML (dataframes), and LaTeX. Live example:

{% jupyter_notebook "/assets/notebooks/demo.ipynb" %}
