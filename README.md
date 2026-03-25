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

The generic `latest` and version tags are published as multi-arch manifests.

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
- This repository does not ship Lazarus/FPC `.deb` packages locally.

## Releases

Pushing a Git tag like `v4.6.0` triggers GitHub Actions to publish:

- versioned arch-specific tags
- versioned multi-arch tag
- `latest` arch-specific tags
- `latest` multi-arch tag

## Contributing

Local image builds, release maintenance, and contributor workflow are documented in [CONTRIBUTING.md](/home/itolstov/Projects/other/lazarus-build-station/CONTRIBUTING.md).

## License

MIT
