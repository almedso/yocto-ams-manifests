# This Dockerfile personalizes a general Yocto builder docker image.
#
# Why is that needed?
#  bitbake must not run as root
#  bitbake must access (private) git repos (of applications) via ssh
#  repo requires a git user config as well as access to manifests and repos
#  via ssh and public key.
#
ARG DOCKER_REMOTE=almedso
ARG YOCTO_BASE_IMAGE=yocto-bitbaker
ARG IMAGE_VERSION=latest
FROM ${DOCKER_REMOTE}/${YOCTO_BASE_IMAGE}:${IMAGE_VERSION}


ARG USERID=1000
ARG GROUPID=1000
ARG USER_NAME="Yocto Builder"
ARG USER_EMAIL="builder@mail-domain.org"

# in case the group id already exists - do not stop
RUN groupadd --gid $GROUPID yocto || true && \
    useradd --uid $USERID --gid $GROUPID --home /home/yocto --create-home --shell /bin/bash yocto
# repo tool expects a git user configured.
RUN echo "[user]"                   > /home/yocto/.gitconfig && \
	echo "    name = $USER_NAME" >> /home/yocto/.gitconfig && \
	echo "	  email = $USER_EMAIL" >> /home/yocto/.gitconfig && \
	echo "[color]" >> /home/yocto/.gitconfig && \
	echo "	  ui = auto" >> /home/yocto/.gitconfig && \
	chown yocto:yocto /home/yocto/.gitconfig
# make sure we can write to mounted volumes where root ownership/permission is
# fixed. (before we switch user)
RUN chmod a+s /usr/bin/chmod && \
    chmod a+s /usr/bin/chown

USER yocto
