# Lazarus Build Station Repository Setup Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Turn this folder into a standalone open-source repository for reproducible Lazarus/FPC Docker build environments.

**Architecture:** Keep the repository flat and small. Use two Dockerfiles for the two builder variants and one shared install script that downloads official Lazarus/FPC Debian packages during image build, installs them, and then builds the Windows cross compiler inside the image.

**Tech Stack:** Docker, Bash, Git, Markdown

---

### Task 1: Normalize repository layout

**Files:**
- Create: `README.md`
- Create: `.gitignore`
- Create: `LICENSE`
- Create: `scripts/install-lazarus-debs.sh`
- Create: `Dockerfile-amd64`
- Create: `Dockerfile-i386`
- Delete: `tmp/Dockerfile`
- Delete: `tmp/Dockerfile.i386`

**Step 1: Define a minimal publishable layout**

Use the repository root for the main docs and Dockerfiles. Keep shared shell logic in `scripts/`.

**Step 2: Replace inherited paths and names**

Remove references to `docker/debs/...` and any source-repository-specific naming.

**Step 3: Add repository metadata**

Write a README, MIT license, and a practical `.gitignore`.

### Task 2: Make the image build self-contained

**Files:**
- Create: `scripts/install-lazarus-debs.sh`
- Create: `Dockerfile-amd64`
- Create: `Dockerfile-i386`

**Step 1: Parameterize Lazarus/FPC package download**

Use build arguments for Lazarus and FPC package versions and for the Debian architecture suffix.

**Step 2: Install official Debian packages during `docker build`**

Download `fpc-laz`, `fpc-src`, and `lazarus-project` from SourceForge and install them in order.

**Step 3: Build Windows cross compilers**

For the amd64 image build `ppcrossx64` targeting `win64`. For the i386 image build `ppcross386` targeting `win32`.

### Task 3: Verify and initialize git

**Files:**
- Modify: `README.md`

**Step 1: Initialize git repository**

Run `git init` in the repository root.

**Step 2: Verify repository structure**

Inspect the resulting tree and git status.

**Step 3: Verify Docker buildability**

Run at least one real `docker build` for each Dockerfile if the environment allows it. If the environment blocks network or Docker daemon access, document the exact blocker in the README and final report.
