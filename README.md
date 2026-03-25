# lazarus-build-station

`lazarus-build-station` is a small standalone repository with Docker-based build environments for Lazarus and Free Pascal projects.

It is intended for reproducible builds, not for running your application in production. The images are designed for:

- native Linux builds
- Windows cross-compilation from Linux
- repeatable local and CI-friendly build setups for external Lazarus/FPC projects

## Included images

This repository contains two builder images:

- `amd64` builder: native Linux x86_64 toolchain plus Windows `win64` cross-compilation
- `i386` builder: native Linux i386 toolchain plus Windows `win32` cross-compilation

Both images download official Lazarus/FPC Debian packages during `docker build`.
The package URLs are pinned by version, and the downloaded `.deb` files are verified against pinned SHA256 checksums during the build.

The `amd64` image uses an Ubuntu 22.04 base. The `i386` image uses a Debian 11 base because current Ubuntu Docker manifests do not publish `linux/386` variants for recent LTS tags.

Current default package versions:

- amd64 Lazarus release directory: `4.6`
- amd64 Lazarus package version: `4.6.0-0`
- i386 Lazarus release directory: `4.4`
- i386 Lazarus package version: `4.4.0-0`
- FPC package version: `3.2.2-210709`

These defaults were chosen because, on 2026-03-25, SourceForge exposes `amd64` Debian packages in the `Lazarus 4.6` directory and `i386` Debian packages in the `Lazarus 4.4` directory.

## Repository layout

```text
.
├── Dockerfile-amd64
├── Dockerfile-i386
├── LICENSE
├── README.md
└── scripts/
    └── install-lazarus-debs.sh
```

## Prerequisites

- Docker with permission to build images
- Internet access during `docker build`
- Enough free disk space for Ubuntu base images, Lazarus/FPC packages, and compiler build artifacts

## Build the amd64 image

```bash
docker build \
  -f Dockerfile-amd64 \
  -t lazarus-build-station:amd64 .
```

To override package versions:

```bash
docker build \
  -f Dockerfile-amd64 \
  -t lazarus-build-station:amd64 \
  --build-arg LAZARUS_RELEASE=4.6 \
  --build-arg LAZARUS_PACKAGE_VERSION=4.6.0-0 \
  --build-arg FPC_PACKAGE_VERSION=3.2.2-210709 .
```

If you override package versions, you should also override the expected checksums:

```bash
docker build \
  -f Dockerfile-amd64 \
  -t lazarus-build-station:amd64 \
  --build-arg LAZARUS_RELEASE=4.6 \
  --build-arg LAZARUS_PACKAGE_VERSION=4.6.0-0 \
  --build-arg FPC_PACKAGE_VERSION=3.2.2-210709 \
  --build-arg FPC_LAZ_SHA256=... \
  --build-arg FPC_SRC_SHA256=... \
  --build-arg LAZARUS_PROJECT_SHA256=... .
```

## Build the i386 image

```bash
docker build \
  -f Dockerfile-i386 \
  -t lazarus-build-station:i386 .
```

If your Docker host requires an explicit platform selection for 32-bit images, use:

```bash
docker build \
  --platform linux/386 \
  -f Dockerfile-i386 \
  -t lazarus-build-station:i386 .
```

## Use the container to build an external project

Mount your Lazarus/FPC project into `/workspace` and run your normal build command inside the container.

Example with `lazbuild`:

```bash
docker run --rm -it \
  -v "$PWD:/workspace" \
  lazarus-build-station:amd64 \
  lazbuild path/to/project.lpi
```

Example with direct `fpc` invocation:

```bash
docker run --rm -it \
  -v "$PWD:/workspace" \
  lazarus-build-station:amd64 \
  fpc src/main.pas
```

For Windows cross-compilation inside the `amd64` image:

```bash
docker run --rm -it \
  -v "$PWD:/workspace" \
  lazarus-build-station:amd64 \
  fpc -Twin64 src/main.pas
```

For Windows cross-compilation inside the `i386` image:

```bash
docker run --rm -it \
  -v "$PWD:/workspace" \
  lazarus-build-station:i386 \
  fpc -Twin32 src/main.pas
```

## How package installation works

During image build, the repository downloads three official Debian packages from the Lazarus SourceForge release tree and installs them in this order:

1. `fpc-laz`
2. `fpc-src`
3. `lazarus-project`

The build verifies the downloaded files with pinned SHA256 checksums before package installation.

The images then build the relevant Windows cross-compiler inside the container.

## Limitations

- The build depends on external package hosting at SourceForge.
- The default package versions and SHA256 checksums are pinned, but they still assume the upstream download layout remains unchanged.
- The `i386` image depends on 32-bit Ubuntu base image availability and may require `--platform linux/386` depending on your Docker setup.
- The `i386` image uses Debian 11 instead of Ubuntu because recent Ubuntu container tags are not published for `linux/386`.
- This repository does not ship Lazarus/FPC `.deb` files locally.
- This project provides build environments only. It does not include project templates, runtime images, or release automation.

## Updating to a newer Lazarus release

When a new Lazarus release appears and you want to refresh the builders:

1. Check that both the `amd64` and `i386` package sets exist upstream if you still need both images.
2. Download the new upstream `.deb` files and compute their `sha256sum` values.
3. Update `LAZARUS_RELEASE`, `LAZARUS_PACKAGE_VERSION`, `FPC_PACKAGE_VERSION`, and the three checksum build arguments in the Dockerfiles.
4. Rebuild both images and verify native Linux and Windows-targeted builds.

## License

MIT
