---
title: "Inline notebook snippets — demo"
category: misc
status: done
updated: 2026-06-04
tags: [meta, syntax]
description: "How to drop notebook-style In[n]/Out[n] cells inline, no .ipynb attachment required."
summary: "How to drop notebook-style In[n]/Out[n] cells inline, no .ipynb attachment required."
---

For quick one-cell illustrations the full `.ipynb` embed is overkill.
The `{% raw %}{% nb_cell %}{% endraw %}` block tag renders an inline
notebook-style cell, auto-numbered, with optional output.

## Plain stdout

{% nb_cell python %}
import numpy as np
print(np.array([1, 2, 3]).sum())
---out
6
{% endnb_cell %}

## Error / traceback

{% nb_cell python %}
1 / 0
---err
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
ZeroDivisionError: division by zero
{% endnb_cell %}

## Multiple outputs in one cell

Mix stdout, image, and HTML in the same cell — sentinels just stack:

{% nb_cell python %}
import matplotlib.pyplot as plt
plt.plot([0, 1, 4, 9, 16, 25])
plt.show()
print("plotted squares")
---out
plotted squares
---img /images/feynman.jpg
{% endnb_cell %}

(The image sentinel takes a normal site path — drop your plot under
`images/` or `assets/` and point at it.)

## Different language

{% nb_cell bash %}
ls _notes/ | wc -l
---out
4
{% endnb_cell %}

## No prompt gutter (clean code snippet)

Pass `no_prompt` to drop the `In[n]:` / `Out[n]:` labels — useful when
the prompt is visual noise:

{% nb_cell python, no_prompt %}
def fuse(imu, lidar):
    return kalman_update(imu, lidar)
---out
<kalman update result>
{% endnb_cell %}

## Reset counter

The In[n]/Out[n] counter auto-increments per page. To restart it
(e.g., a new "session" within one note), drop:

```liquid
{% raw %}{% nb_reset %}{% endraw %}
```

## Syntax reference

```liquid
{% raw %}{% nb_cell <language>[, no_prompt] %}
<code>
---out
<plain text output>
---err
<error / stderr text>
---img <path>
---html
<raw html>
{% endnb_cell %}{% endraw %}
```

Supported languages: `python`, `bash`, `ruby`, `js`, `cpp`, `rust`,
`go`, `r`, `julia`. Unknown → falls back to `python`.

Use the full `{% raw %}{% jupyter_notebook %}{% endraw %}` embed when
you want a multi-cell `.ipynb` with real plots, dataframes, and LaTeX
outputs. Use `nb_cell` for a quick illustration that lives in the
note itself.
