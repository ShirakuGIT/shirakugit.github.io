---
title: "nanoGPT from scratch — Karpathy walkthrough"
category: tutorial
status: wip
updated: 2026-06-04
source: "https://github.com/karpathy/nanoGPT"
tags: [llm, transformers, karpathy, pytorch]
description: "My notes as I implement nanoGPT line by line — character-level on tinyshakespeare, then word-level."
summary: "My notes as I implement nanoGPT line by line — character-level on tinyshakespeare, then word-level."
---

Following Karpathy's [Let's build GPT from scratch][yt] video and the
[nanoGPT][nano] repo. Reimplementing each piece in a fresh notebook to
make sure I can derive it without copy-paste.

[yt]: https://www.youtube.com/watch?v=kCc8FmEb1nY
[nano]: https://github.com/karpathy/nanoGPT

## Plan

1. Bigram baseline on tinyshakespeare.
2. Add self-attention → multi-head → blocks.
3. Add positional embeddings + layer norm + residual.
4. Train on GPU, sample.
5. Swap dataset (my own corpus).

## Live notebook

(Will replace with my actual training notebook — for now the embed
demo proves the wiring works.)

{% jupyter_notebook "/assets/notebooks/demo.ipynb" %}

## Key derivations (TODO — fill as I go)

- Scaled dot-product attention as a soft k-NN over keys.
- Why the `/√d_k` scaling matters (variance argument).
- Causal mask = upper-triangular `-inf`.
- Why pre-LayerNorm is more stable than post-LN.

## Bugs I hit

- Forgot to detach hidden state when iterating batches — gradient
  graph exploded. Lesson: in a training loop with custom slicing,
  print `loss.grad_fn` once to sanity check.
- Off-by-one in the targets shift: `y = x[:, 1:]` not `x[:, :-1]`.
