#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: $0 <amd64|i386>" >&2
  exit 1
fi

arch="$1"

case "$arch" in
  amd64)
    lazarus_path="${LAZARUS_PATH_AMD64:-Lazarus Linux amd64 DEB}"
    ;;
  i386)
    lazarus_path="${LAZARUS_PATH_I386:-Lazarus Linux i386 DEB}"
    ;;
  *)
    echo "unsupported architecture: $arch" >&2
    exit 1
    ;;
esac

lazarus_release="${LAZARUS_RELEASE:-4.4}"
lazarus_package_version="${LAZARUS_PACKAGE_VERSION:-4.4.0-0}"
fpc_package_version="${FPC_PACKAGE_VERSION:-3.2.2-210709}"
download_root="${DOWNLOAD_ROOT:-https://sourceforge.net/projects/lazarus/files}"
download_dir="/tmp/lazarus-debs"
lazarus_path_encoded="${lazarus_path// /%20}"
lazarus_release_encoded="${lazarus_release// /%20}"
fpc_laz_sha256="${FPC_LAZ_SHA256:-}"
fpc_src_sha256="${FPC_SRC_SHA256:-}"
lazarus_project_sha256="${LAZARUS_PROJECT_SHA256:-}"

mkdir -p "$download_dir"
cd "$download_dir"

base_url="${download_root}/${lazarus_path_encoded}/Lazarus%20${lazarus_release_encoded}"
packages=(
  "fpc-laz_${fpc_package_version}_${arch}.deb"
  "fpc-src_${fpc_package_version}_${arch}.deb"
  "lazarus-project_${lazarus_package_version}_${arch}.deb"
)
checksums=(
  "$fpc_laz_sha256"
  "$fpc_src_sha256"
  "$lazarus_project_sha256"
)

for package in "${packages[@]}"; do
  wget --progress=dot:giga --retry-connrefused --waitretry=1 -O "$package" "${base_url}/${package}/download"
done

if [[ -n "$fpc_laz_sha256" && -n "$fpc_src_sha256" && -n "$lazarus_project_sha256" ]]; then
  : > SHA256SUMS
  for i in "${!packages[@]}"; do
    printf '%s  %s\n' "${checksums[$i]}" "${packages[$i]}" >> SHA256SUMS
  done
  sha256sum -c SHA256SUMS
fi

apt-get update
apt-get install -y --no-install-recommends ./*.deb
rm -rf "$download_dir" /var/lib/apt/lists/*
