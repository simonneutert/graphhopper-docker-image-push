#!/bin/bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage: $0 [<tag>]

Prepares a local build context for GraphHopper:
- clones or updates the 'graphhopper' repository
- optionally checks out a tag
- ensures a Docker Buildx builder named 'graphhopperbuilder' exists

After running this script you can build locally with Buildx, for example:
  docker buildx build --platform linux/amd64,linux/arm64 -t ghcr.io/<owner>/graphhopper:<tag> .

If no <tag> is provided the script will leave the repository on 'master' and
the suggested local image tag will be 'local'.
USAGE
}

if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
  usage
  exit 0
fi

TAG="${1:-local}"

# If GHCR_OWNER is set in the environment we'll show a ready-to-use image name,
# otherwise present a generic placeholder (<owner>) so the user can replace it.
if [ -n "${GHCR_OWNER:-}" ]; then
  OWNER_DISPLAY="${GHCR_OWNER}"
else
  OWNER_DISPLAY="<owner>"
fi

echo "Preparing local build context (tag=${TAG})..."

if [ ! -d graphhopper ]; then
  echo "Cloning graphhopper repository..."
  git clone https://github.com/graphhopper/graphhopper.git
else
  echo "Updating existing graphhopper repository..."
  git -C graphhopper fetch --prune
  git -C graphhopper checkout master || true
  git -C graphhopper pull --ff-only || true
fi

if [ "${TAG}" != "local" ]; then
  echo "Checking out tag/commit: ${TAG}"
  git -C graphhopper checkout --detach "${TAG}" || {
    echo "Failed to checkout ${TAG}. Ensure the tag/commit exists in https://github.com/graphhopper/graphhopper"
    exit 1
  }
fi

echo "Ensuring Docker Buildx builder 'graphhopperbuilder' exists..."
if docker buildx inspect graphhopperbuilder >/dev/null 2>&1; then
  echo "Using existing buildx builder 'graphhopperbuilder'"
  docker buildx use graphhopperbuilder || true
else
  echo "Creating buildx builder 'graphhopperbuilder'"
  docker buildx create --use --name graphhopperbuilder
fi

echo
echo "Ready. Suggested local build command:"
echo
echo "  docker buildx build --platform linux/amd64,linux/arm64 -t ghcr.io/${OWNER_DISPLAY}/graphhopper:${TAG} ."
echo
echo "Notes:"
echo "- This script does not push images. To push, add '--push' to your build command or use GH Actions."
echo "- To remove the builder: 'docker buildx rm graphhopperbuilder'"

exit 0
