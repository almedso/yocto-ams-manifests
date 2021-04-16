#!/usr/bin/env bash

# figure out base dir
PRIV_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# default image name and version
# can be injected from outside
YOCTO_BASE_IMAGE=${YOCTO_BASE_IMAGE:-"yocto-bitbaker"}
DOCKER_REMOTE=${DOCKER_REMOTE:-"almedso"}
YOCTO_IMAGE="${DOCKER_REMOTE}/${YOCTO_BASE_IMAGE}"
IMAGE_VERSION=${IMAGE_VERSION:-"latest"}


echo "INFO: Build the PERSONALIZED image: my-${YOCTO_BASE_IMAGE}"
docker build --build-arg USERID=$(id -u) --build-arg GROUPID=$(id -g) \
   --build-arg DOCKER_REMOTE=${DOCKER_REMOTE} \
   --build-arg YOCTO_BASE_IMAGE=${YOCTO_BASE_IMAGE} \
   --build-arg IMAGE_VERSION=${IMAGE_VERSION} \
   -t my-${YOCTO_BASE_IMAGE}  --file ${PRIV_DIR}/Dockerfile .
