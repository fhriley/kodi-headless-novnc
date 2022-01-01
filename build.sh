set -x
set -e

BASE_IMAGE="ubuntu:22.04"
KODI_VER=19.3
KODI_NAME=Matrix
USER=fhriley
IMAGE=kodi-headless-novnc

BUILD_ARGS="--build-arg BASE_IMAGE=$BASE_IMAGE --build-arg KODI_VER=$KODI_VER --build-arg KODI_NAME=$KODI_NAME"
PLATFORMS="linux/amd64,linux/arm64/v8,linux/arm/v7"

docker login
docker buildx build $BUILD_ARGS --platform $PLATFORMS --tag $USER/$IMAGE:$KODI_VER --tag $USER/$IMAGE:latest --push --pull .

#docker manifest create $USER/$IMAGE:latest $USER/$IMAGE:$KODI_VER
#docker manifest push --purge $USER/$IMAGE:latest
