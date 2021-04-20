# Build Context Configuration - LOCAL DOCKER DEV

bare metal development build is integrated as follow:

* use local docker container
* no publishing (manunally copy over packages or start qemu)
* sstate and download cache injected from  *../cache*
* ronto can be used

## External requirements:

* cache folder must be accessible and provide sufficient storage capacity
* docker accessible in the developers machine
