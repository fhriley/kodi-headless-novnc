set -x
set -e

docker buildx create --name cluster --platform linux/amd64
DOCKER_HOST=tcp://arm32:2376 docker buildx create --name cluster --append --platform linux/arm/v7
DOCKER_HOST=tcp://arm64:2376 docker buildx create --name cluster --append --platform linux/arm64
docker buildx inspect --bootstrap cluster
docker buildx use cluster
