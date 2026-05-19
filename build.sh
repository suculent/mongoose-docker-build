DOCKER_HUB_REPO=suculent/$(basename $(pwd))
docker build --platform linux/amd64 . -t $DOCKER_HUB_REPO

