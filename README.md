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

Tag meaning:

- `latest`: multi-arch manifest; Docker pulls the variant matching the host platform when available
- `latest-amd64`: explicit `amd64` builder image
- `latest-i386`: explicit `i386` builder image
- `latest-amd64-qt5`: explicit `amd64` builder image with Qt5 widgetset prebuilt for Linux
- `4.6.0`: multi-arch manifest for release `4.6.0`
- `4.6.0-amd64`: explicit `amd64` image for release `4.6.0`
- `4.6.0-i386`: explicit `i386` image for release `4.6.0`
- `4.6.0-amd64-qt5`: explicit `amd64` image with Qt5 widgetset prebuilt for release `4.6.0`

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

The repository currently publishes two builder variants:

- `amd64`: Ubuntu 22.04 base, native Linux x86_64 build environment, Windows `win64` cross-compiler
- `i386`: Debian 11 base, native Linux i386 build environment, Windows `win32` cross-compiler

Both variants currently target:

- Lazarus `4.6.0-0`
- FPC `3.2.2-210709`

During image build, packages are downloaded from `download.lazarus-ide.org`, pinned by version, and verified with SHA256 checksums before installation.

## Prerequisites and limitations

- Docker is required.
- Internet access is required only when building the images locally.
- The published images depend on upstream Lazarus package availability when the repository is updated for future releases.
- The `i386` image uses Debian 11 because recent Ubuntu base images are not published for `linux/386`.
- `latest-amd64-qt5` is an optional separate image for Qt5 and does not replace existing Gtk2 images.
- This repository does not ship Lazarus/FPC `.deb` packages locally.

## Releases

Pushing a Git tag like `v4.6.0` triggers GitHub Actions to publish:

- versioned arch-specific tags
- versioned multi-arch tag
- `latest` arch-specific tags
- `latest` multi-arch tag
- versioned Qt5 tag for `amd64` (`<version>-amd64-qt5`)
- `latest-amd64-qt5`

## Contributing

Local image builds, release maintenance, and contributor workflow are documented in [CONTRIBUTING.md](/home/itolstov/Projects/other/lazarus-build-station/CONTRIBUTING.md).

## Example repository

A companion repository named `lazarus-build-station-example` is planned for this project.

It will contain a small Lazarus/FPC example application built with `lazarus-build-station`, including a non-trivial external component so the repository shows a realistic builder workflow rather than only a plain hello world.

## License

MIT
