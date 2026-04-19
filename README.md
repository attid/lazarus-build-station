# lazarus-build-station

`lazarus-build-station` is a Docker-based build environment for Lazarus and Free Pascal projects.

It is a builder image, not a runtime container. The goal is reproducible Lazarus/FPC builds for external projects, including native Linux builds and Windows cross-compilation from Linux.

## Available images

Published images live in GHCR:

- `ghcr.io/attid/lazarus-build-station:latest`
- `ghcr.io/attid/lazarus-build-station:latest-amd64`
- `ghcr.io/attid/lazarus-build-station:latest-i386`
- `ghcr.io/attid/lazarus-build-station:4.6.0`
- `ghcr.io/attid/lazarus-build-station:4.6.0-amd64`
- `ghcr.io/attid/lazarus-build-station:4.6.0-i386`
- `ghcr.io/attid/lazarus-build-station:latest-amd64-qt5`
- `ghcr.io/attid/lazarus-build-station:4.6.0-amd64-qt5`
- `ghcr.io/attid/lazarus-build-station:latest-amd64-compat`
- `ghcr.io/attid/lazarus-build-station:4.6.0-amd64-compat`
- `ghcr.io/attid/lazarus-build-station:latest-i386-compat`
- `ghcr.io/attid/lazarus-build-station:4.6.0-i386-compat`

Tag meaning:

- `latest`: multi-arch manifest; Docker pulls the variant matching the host platform when available
- `latest-amd64`: explicit `amd64` builder image
- `latest-i386`: explicit `i386` builder image
- `latest-amd64-qt5`: explicit `amd64` builder image with Qt5 widgetset prebuilt for Linux
- `latest-amd64-compat`: explicit `amd64` builder image on Ubuntu 18.04 base (glibc 2.27) for running the produced binaries on older target systems
- `latest-i386-compat`: explicit `i386` builder image on Ubuntu 18.04 base (glibc 2.27) for older target systems
- `4.6.0`: multi-arch manifest for release `4.6.0`
- `4.6.0-amd64`: explicit `amd64` image for release `4.6.0`
- `4.6.0-i386`: explicit `i386` image for release `4.6.0`
- `4.6.0-amd64-qt5`: explicit `amd64` image with Qt5 widgetset prebuilt for release `4.6.0`
- `4.6.0-amd64-compat`: explicit `amd64` glibc-2.27 compat image for release `4.6.0`
- `4.6.0-i386-compat`: explicit `i386` glibc-2.27 compat image for release `4.6.0`


## Quick start

Pull the published image:

```bash
docker pull ghcr.io/attid/lazarus-build-station:latest
```

Run it against your project directory:

```bash
docker run --rm -it \
  -v "$PWD:/workspace" \
  ghcr.io/attid/lazarus-build-station:latest \
  lazbuild path/to/project.lpi
```

Direct `fpc` usage works too:

```bash
docker run --rm -it \
  -v "$PWD:/workspace" \
  ghcr.io/attid/lazarus-build-station:latest \
  fpc src/main.pas
```

Use the Qt5 image (amd64 only):

```bash
docker run --rm -it \
  -v "$PWD:/workspace" \
  ghcr.io/attid/lazarus-build-station:latest-amd64-qt5 \
  fpc -MObjFPC -dLCL -dLCLqt5 -Fu/usr/share/lazarus/4.6.0/lcl/units/x86_64-linux/qt5 \
      -Fu/usr/share/lazarus/4.6.0/lcl/units/x86_64-linux \
      -Fu/usr/share/lazarus/4.6.0/components/lazutils/lib/x86_64-linux \
      -Fu/usr/share/lazarus/4.6.0/packager/units/x86_64-linux \
      -o/workspace/app /workspace/app.lpr
```

## Cross-compilation examples

Windows `win64` from the `amd64` builder:

```bash
docker run --rm -it \
  -v "$PWD:/workspace" \
  ghcr.io/attid/lazarus-build-station:latest-amd64 \
  fpc -Twin64 src/main.pas
```

Windows `win32` from the `i386` builder:

```bash
docker run --rm -it \
  -v "$PWD:/workspace" \
  ghcr.io/attid/lazarus-build-station:latest-i386 \
  fpc -Twin32 src/main.pas
```

## What is inside

The repository currently publishes the following builder variants:

- `amd64`: Ubuntu 22.04 base, native Linux x86_64 build environment, Windows `win64` cross-compiler
- `i386`: Debian 11 base, native Linux i386 build environment, Windows `win32` cross-compiler
- `amd64-qt5`: `amd64` image extended with Qt5 widgetset prebuilt for Linux
- `amd64-compat`: Ubuntu 18.04 base, same tooling as `amd64`; produces binaries that run on older Linux targets (glibc 2.27+)
- `i386-compat`: Ubuntu 18.04 (i386) base, same tooling as `i386`; produces binaries that run on older Linux targets (glibc 2.27+)

All variants currently target:

- Lazarus `4.6.0-0`
- FPC `3.2.2-210709`

During image build, packages are downloaded from `download.lazarus-ide.org`, pinned by version, and verified with SHA256 checksums before installation.

### glibc compatibility

Linux binaries are backward-compatible only one way: a binary linked against glibc `X` will run on systems with glibc `>= X`, not lower. Pick the variant whose base matches (or is older than) the oldest target system you need to support.

| Variant | Base image | glibc floor | Runs on (examples) |
|---|---|---|---|
| `amd64` | Ubuntu 22.04 | 2.35 | Ubuntu 22.04+, Debian 12+ |
| `i386` | Debian 11 | 2.31 | Debian 11+, Ubuntu 20.04+ |
| `amd64-qt5` | Ubuntu 22.04 | 2.35 | same as `amd64` |
| `amd64-compat` | Ubuntu 18.04 | 2.27 | Ubuntu 18.04+, Debian 10+, RHEL 8+ |
| `i386-compat` | Ubuntu 18.04 | 2.27 | Ubuntu 18.04+, Debian 10+ |

Example run using the compat image:

```bash
docker run --rm -it \
  -v "$PWD:/workspace" \
  ghcr.io/attid/lazarus-build-station:latest-amd64-compat \
  lazbuild path/to/project.lpi
```

## Prerequisites and limitations

- Docker is required.
- Internet access is required only when building the images locally.
- The published images depend on upstream Lazarus package availability when the repository is updated for future releases.
- The `i386` image uses Debian 11 because recent Ubuntu base images are not published for `linux/386`.
- `latest-amd64-qt5` is an optional separate image for Qt5 and does not replace existing Gtk2 images.
- This repository does not ship Lazarus/FPC `.deb` packages locally.

## Releases

Pushing a Git tag like `v4.6.0` triggers GitHub Actions to publish:

- versioned arch-specific tags (including `-amd64-compat` and `-i386-compat`)
- versioned multi-arch tag (combines only the default `-amd64` and `-i386` variants)
- `latest` arch-specific tags (including `-amd64-compat` and `-i386-compat`)
- `latest` multi-arch tag
- versioned Qt5 tag for `amd64` (`<version>-amd64-qt5`)
- `latest-amd64-qt5`

The same workflow can be triggered manually from the GitHub Actions "Release Images" page via `workflow_dispatch`; a `version` input is required.

## Contributing

Local image builds, release maintenance, and contributor workflow are documented in [CONTRIBUTING.md](/home/itolstov/Projects/other/lazarus-build-station/CONTRIBUTING.md).

## Example repository

A companion repository named `lazarus-build-station-example` is planned for this project.

It will contain a small Lazarus/FPC example application built with `lazarus-build-station`, including a non-trivial external component so the repository shows a realistic builder workflow rather than only a plain hello world.

## License

MIT
