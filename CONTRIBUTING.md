# Contributing

## Local builds

Build the `amd64` image:

```bash
docker build \
  -f Dockerfile-amd64 \
  -t lazarus-build-station:amd64 .
```

Build the `i386` image:

```bash
docker build \
  --platform linux/386 \
  -f Dockerfile-i386 \
  -t lazarus-build-station:i386 .
```

## Overriding package versions

If you change Lazarus or FPC versions, you should also update the expected checksums.

Example:

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

## Verification

Recommended local verification commands:

```bash
docker build -f Dockerfile-amd64 -t lazarus-build-station:test-amd64 .
docker build --platform linux/386 -f Dockerfile-i386 -t lazarus-build-station:test-i386 .
docker run --rm lazarus-build-station:test-amd64 bash -lc 'fpc -iV && command -v lazbuild && command -v ppcrossx64'
docker run --rm lazarus-build-station:test-i386 bash -lc 'fpc -iV && command -v lazbuild && command -v ppcross386'
```

## Updating to a new Lazarus release

1. Check that both `amd64` and `i386` package sets exist at `download.lazarus-ide.org`.
2. Download the new `.deb` files and compute `sha256sum` values.
3. Update `LAZARUS_RELEASE`, `LAZARUS_PACKAGE_VERSION`, `FPC_PACKAGE_VERSION`, and checksum arguments in the Dockerfiles.
4. Rebuild both images locally.
5. Push `main`, then push a release tag like `v4.7.0`.

## Release publishing

GitHub Actions publishes images to:

- `ghcr.io/attid/lazarus-build-station:<version>-amd64`
- `ghcr.io/attid/lazarus-build-station:<version>-i386`
- `ghcr.io/attid/lazarus-build-station:<version>`
- `ghcr.io/attid/lazarus-build-station:latest-amd64`
- `ghcr.io/attid/lazarus-build-station:latest-i386`
- `ghcr.io/attid/lazarus-build-station:latest`
