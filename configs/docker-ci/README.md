# Build Context Configuration - DOCKER HEADLESS CI

Headless build is integrated as follow:

* dedicated build containers
* shared external publish and cache volumes
* project home is this folder
* ronto is used to build
* publishing is configured (images and packages)

## External requirements:

* exterenal volumes *cache* and *download* exist *all users* have rw access
* publishing folder is picked up from nginx publisher
