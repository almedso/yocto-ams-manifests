## General

This repository contains configuration to build **ams yocto project**.

A **yocto project** is considered here as all configuration, specifications and
procedures to build deploy-able linux images and packages for a group of
applications and hardware devices using Yocto.


This repository contains *manifest files* to pull more configuration and
specification sources (yocto layers and recipes) via google repo tool
as well as scripts and *entry point configurations* to setup a certain Yocto
build environment either bare metal or virtual docker container

*ams* is a shortcut for AlMedSo yocto meta builds and denotes the
Yocto ams distribution


## Directory Structure

```
├── configs
│   ├── docker-ci
│   └── local-dev
├── default.xml -> repo-manifests/integration/dunfell.xml
├── LICENSE
├── README.md
├── repo-manifests
│   ├── experimental
│   └── integration
└── scripts
    └── privatized-docker-image
```

| Folder/ File    | Description                                           |
|-----------------|-------------------------------------------------------|
| scripts         | Home for helper scripts to setup stuff                |
| repo-manifests  | Home of all repo manifests specifications             |
| default.xml     | symbolic link to a manifest that repo uses as default |
| configs         | Home of "meta" configurations                         |


## Required Tools

### google repo tool

* is needed to retrieve yocto layer specification repositories
* input are manifest files *default.xml* and other manifest located in
* *repo-manifests* directory
* this tool is mandatory

### Build Environment

A build environment is needed to actually run yocto builds. It could be
either a bare metal build environment or docker build environment.

#### bare metal Yocto build environment

A host, that allows to execute Yocto builds:

* Passes bitbaker sanity checks (proper Linux OS derivative and version)
* All the prerequisite packages are installed
* Setting up a bare metal environment is described in the Yocto manual

#### docker

Docker the and ability to build docker images and manage docker containers.

* A "privatized docker container" is used for building. Yocto does not allow
  running as root.
* The privatized container can be build calling

    ```
    ./scripts/privatized-docker-image/build-my-image.sh
    ```

* It will result in a local docker image called *my-yocto-bitbaker*. See the
  README.md in /scripts/privatized-docker-image

### Ronto

Ronto is a tool developed and maintained by almedso to support yocto build
development and automation processes.

It s available via `pip3 install -U ronto` and documentation at
https://ronto.readthedocs.io.

ronto cli is self-explaining via `ronto --help`

## Usage

### Usage without ronto

1.  Fetch all Yocto layer and recipes

    Initialize repo:
    ```
    repo init -u . -m repo-manifests/integration/dunfell.xml
    ```
    Since this git repository contains all the repo manifests, repo references
    itself via the url option `-u .`

    Fetch and update the git repositories:
    ```
    repo sync
    ```

2.  Initialize the build environment
    ```
    source sources/ams/scripts/ams-init-build-env
    ```

3.  Build something
    ```
    build$ MACHINE=ricardo bitbake ams-image
    ```

### Usage with ronto

TODO

### Usage (Docker context)

1. Create docker container

    (first time only; docker only)
    ```
    ./scripts/privatized-docker-image/build-my-image.sh
    ```

    If a docker container exists check if it is up to date.
    (Probably only required if you refer on 'latest' image version)

    You force a clean build if you
    ```
    docker rmi almedso/yocto-bitbaker my-yocto-bitbaker
    ```
    (This works under the assumption you have not changed any naming)


2.  Start the container

    For ease of usage we symlink the respective docker-compose
    into this root folder. Also, it is essential to do so since the
    setup of the docker-compose.yml is made with reference it is
    located in project root.

    ```
    ln -s configs/docker-ci/docker-compose.yml docker-compose.yml
    ```

    Run the container as a background service (-d).
    ```
    docker-compose up -d
    ```
    creates a container like:
    ```
    docker ps -a
    CONTAINER ID   IMAGE                                    COMMAND                  CREATED         STATUS         PORTS                                      NAMES
    2c231ff6d8e6   my-yocto-bitbaker:latest                 "/bin/bash -c 'while…"   8 seconds ago   Up 7 seconds                                              dockerci_my-yocto-builder_1

    ```
    Note:

        It is important that a *docker-compose.yml* is in access.
        This is what we achived  by sym-linking.


3.  Exec into the container

    While the container is running exec into it and do what you need to do.
    ```
    docker-compose exec my-yocto-builder /bin/bash
    ```
    Note: It is important that a *docker-compose.yml* is in access.

2.  Stop the container

    ```
    docker-compose -f configs/docker-ci/docker-compose.yml down
    ```


