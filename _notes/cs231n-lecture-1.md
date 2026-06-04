---
title: "CS231n — Lecture 1: History of computer vision"
category: course
status: wip
updated: 2026-06-04
source: "http://cs231n.stanford.edu/"
tags: [cs231n, computer-vision, stanford]
summary: "Course intro: from Hubel & Wiesel cats to ImageNet to ViTs. Setting up the framing for the rest of the course."
---

## Course meta

- **Stanford CS231n** — Deep Learning for Computer Vision.
- Reading-along the 2024 lecture set.
- I'll keep one note per lecture, plus separate notes for assignments.

## Lecture 1 — visual recognition through the years

### Biological roots

- Hubel & Wiesel (1959) — single-cell recordings in cat V1.
- Found simple cells responding to **oriented edges**, complex cells
  pooling over position.
- Inspired the hierarchical structure later baked into CNNs.

### Pre-deep era

- **Block world** (Roberts, 1963) — first attempt at 3D recovery.
- **Generalized cylinders / pictorial structures** — parts + springs.
- **SIFT** (Lowe, 1999) — keypoint matching that actually worked.
- **HoG + linear SVM** (Dalal & Triggs, 2005) — pedestrian detection.
- **PASCAL VOC** & later **ImageNet** drove benchmark culture.

### Deep era

- **AlexNet** (Krizhevsky 2012) — first CNN to crush ImageNet.
  - 8 layers, ReLU, dropout, GPU training.
- **VGG / GoogLeNet / ResNet** — depth + skip connections.
- **Vision Transformers** (Dosovitskiy 2020) — attention over patches.
- Recent: foundation models (SAM, DINO, CLIP), 3D vision (NeRF, GS).

## My open questions

1. How much of the CNN inductive bias is *necessary* vs *helpful*?
   ViTs say less than we thought, but small-data regimes still favor CNNs.
2. What's the cleanest way to think about *equivariance* in modern
   detectors? Group-equivariant convs vs learned augmentation.
3. Where does 3D fit? Is "lift to 3D, reason, project" coming back?

## Math placeholder

A convolution in 2D:

$$ (f * g)(x, y) = \sum_{i,j} f(i, j) \, g(x - i, y - j) $$

Will revisit equivariance properly when I do the assignment.

## Next

- Lecture 2: image classification pipeline (k-NN, linear classifier).
- Assignment 1 setup.
