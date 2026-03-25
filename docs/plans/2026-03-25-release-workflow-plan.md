# Release Workflow Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Switch package downloads to the official Lazarus host, align both images on Lazarus 4.6, and add a GitHub Actions workflow that publishes release-tagged images to GHCR.

**Architecture:** Keep the repository simple: Dockerfiles remain the source of truth for pinned package versions and checksums, the installer script only handles download and verification, and one release workflow reacts to Git tags. Docker image tags will use the Git release version plus architecture-specific suffixes so the repository can publish both builders from one release safely.

**Tech Stack:** Docker, GitHub Actions, GHCR, bash

---

### Task 1: Update the release source and pinned package data

**Files:**
- Modify: `scripts/install-lazarus-debs.sh`
- Modify: `Dockerfile-i386`
- Modify: `README.md`

**Step 1:** Switch the default download root from SourceForge to `https://download.lazarus-ide.org`.

**Step 2:** Update `Dockerfile-i386` to Lazarus `4.6` and replace the three i386 SHA256 values with fresh checksums from the official host.

**Step 3:** Update the README so it describes the official Lazarus host and a unified Lazarus release baseline if verification succeeds.

### Task 2: Add release automation

**Files:**
- Create: `.github/workflows/release-images.yml`
- Modify: `README.md`

**Step 1:** Add a workflow triggered by Git tags matching `v*`.

**Step 2:** Build and push:
- `ghcr.io/attid/lazarus-build-station:<version>-amd64`
- `ghcr.io/attid/lazarus-build-station:<version>-i386`
- `ghcr.io/attid/lazarus-build-station:latest-amd64`
- `ghcr.io/attid/lazarus-build-station:latest-i386`

**Step 3:** Document the release/tagging behavior in the README.

### Task 3: Verify the release baseline

**Files:**
- No code changes required

**Step 1:** Rebuild the `amd64` image.

**Step 2:** Rebuild the `i386` image with `--platform linux/386`.

**Step 3:** Run short container smoke checks to confirm `fpc`, `lazbuild`, and the Windows cross-compiler binaries are present.
