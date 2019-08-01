# General

This is Google-Repo to support AlMedSo yocto meta builds.


## Yocto / Jenkins CI high level concepts

### Shared download cache kept forever

**Requirement:** Assure reprodusability w/o external dependencies

This implies that all sources that are pulled from extern need to be internally mirrored
and that system reconstruction can happen without access to the internet

**Solution:**

* Yocto caches all downloads it takes to safe network bandwidth.
* We setup a *download cache* that is *global* to all builds.
* This *download cache* directory needs to be included into the *backup* and shall be kept forever
* This global download cache dir needs to be configured in *DL_DIR* variable via *site.conf* or *local.conf*


### No shared state reuse

**Requirement:** Assure full independence of builds for robustness

This implies implies that any side effects must be suppressed.
Potentially higher computing needs are considered.

**Solution:**

* Yocto shared state caches are removed before each build.



## How to build the YOCTO images and applications


### Prepare the environment

These tools are need by yocto on e.g. ubuntu 16.04
```
sudo apt-get install git build-essential python diffstat texinfo gawk chrpath dos2unix wget unzip socat doxygen lib32stdc++6 lib32ncurses5 lib32z1 libc6-dev-i386 cpio gcc-multilib
```

Jenkins use the build server directly to compile and create the code coverage report for that case some additional
package are necessary.


```
sudo apt-get install autoconf automake libtool curl make g++ unzip libssl-dev

```

Google Repo-tool must be installed upfront:

```
sudo mkdir -p /opt/bin
sudo chown -R tall: bin
cd /opt/bin
curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > ./repo
chmod a+x repo
cd -
# make the tool accessible to via PATH variable
echo "export PATH=/opt/bin/:$PATH" >> ~/.bashrc
. ~/.bashrc

```


We need the bash script interpreter (dbkg-reconfigure dash) none-interactively:

```
sudo echo "dash dash/sh boolean false" | debconf-set-selections
sudo DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

```

####  Further recommendations

Define the git build user and git settings in order to silence google-repo.

```
git config --global user.email "<your-email-account>@your-company.com"
git config --global user.name "<your full name>"
git config --global http.sslcainfo /etc/ssl/certs/ca-certificates.crt
```

#### Example of a BB site configuration file ###

    #
    # local.conf covers user settings, site.conf covers site specific information
    # such as proxy server addresses and optionally any shared download location
    #
    # SITE_CONF_VERSION is increased each time $HOME/{.yocto,.oe}/site.conf
    # changes incompatibly
    SCONF_VERSION = "1"

    # Uncomment to cause CVS to use the proxy host specified
    #CVS_PROXY_HOST = "proxy.example.com"
    #CVS_PROXY_PORT = "81"

    # To use git with a proxy, you must use an external git proxy command, such as
    # the one provided by scripts/oe-git-proxy.sh. To use this script, copy it to
    # your PATH and uncomment the following:
    #GIT_PROXY_COMMAND ?= "oe-git-proxy"
    #ALL_PROXY ?= "socks://socks.example.com:1080"
    #or
    #ALL_PROXY ?= "https://proxy.example.com:8080"
    # If you wish to use certain hosts without the proxy, specify them in NO_PROXY.
    # See the script for details on syntax.

    # Uncomment this to use a shared download directory
    #DL_DIR = "/some/shared/download/directory/"

    # Uncomment this to use a shared state cache directory differentiate by machine
    #SSTATE_DIR = "/some/shared/sstate-cache/directory/${MACHINE}"

    # Uncomment this to support deletion of temporary workspace, which can ease
    # your hard drive demands during builds. Once the build system generates the
    # packages for a recipe, the work files for that recipe under the
    # ${TMPDIR}/work directory are no longer needed. However, by default, the
    # build system preserves these files for inspection and possible debugging
    # purposes. If you would rather have these files deleted to save disk space
    # as the build progresses, you can globally inherit the rm_work class and
    # then provide the exclusion list to exclude some recipes from having their
    # work directories deleted by rm_work.
    #INHERIT += "rm_work"
    #RM_WORK_EXCLUDE += "busybox eglibc"

    # Uncomment this to use and/or create a local source mirror PREMIRRORS that will
    # be used before fetching from original SRC_URI. To use SOURCE_MIRROR_URL, you
    # must globally inherit the own-mirrors class and then provide the URL to your
    # mirror. You can specify only a single URL in SOURCE_MIRROR_URL.
    #INHERIT += "own-mirrors"
    #SOURCE_MIRROR_URL = "http://domain.tld/local-source-mirror"
    #SOURCE_MIRROR_URL = "file:///some/source/mirror/directory"

    # This statement tells BitBake to issue an error instead of trying to access
    # the Internet. This technique is useful if you want to ensure code builds
    # only from local sources.
    #BB_NO_NETWORK = "1"

    # This statement limits the build system to pulling source from the PREMIRRORS
    # only. Again, this technique is useful for reproducing builds.
    #BB_FETCH_PREMIRRORONLY = "1"

    # This statement tells the build system to generate mirror tarballs. This
    # technique is useful if you want to create a mirror server. If not, however,
    # the technique can simply waste time during the build.
    #BB_GENERATE_MIRROR_TARBALLS = "1"

    # Disable QA sanity checks for specific packages.
    # See: http://www.yoctoproject.org/docs/1.5/ref-manual/ref-manual.html#ref-classes-insane
    # See: https://bugzilla.yoctoproject.org/show_bug.cgi?id=5243
    #INSANE_SKIP_linux-cubox-i = "installed-vs-shipped"


### Create an image build

Create location and checkout recipes

```
$ cd $YOCTO_BASE_DIR/img-iot-ci
$ mkdir -p feature_example-feature
$ cd feature_example-feature
$
$ # note replace '_' in directory name by '/' in branch name
$ repo init -u ssh://git@github.com:almedso/repo-yocto.git -b feature/example-feature
$ repo sync
```

Initialize the yocto environment and build the image(s) (mainly pick )
and patch conf/local.conf accordingly
in conf/local.conf *distro* and *machine* are already pre-configured

```
rm -rf build  # in case it exists

# pick defaults source for local.conf and bblayers.conf and initialize the environment
TEMPLATECONF=$(pwd)/sources/ams/conf source sources/poky/oe-init-build-env build # creates build directory


# (in build dir) create site.conf with global stuff that is sourced before local.conf
echo "DL_DIR = \"$YOCTO_BASE_DIR/download-cache\" " > conf/site.conf

```

Build all the images targets

```
# provide tooling for wic installer, since image create via wic
# is integrated into all images.
bitbake dosfstools-native # create arbitrary tools
bitbake mtools-native     # for sd-card creation
bitbake parted-native     # all of them only once

# make sure we do not run into problems with protobuf fetch all first (workaround)
bitbake iot-image -c fetchall

# build (all) images
bitbake iot-image-min
bitbake iot-image
bitbake iot-image-dev
```

### Create the all sd-card images

SD-CARD images can be created independently upon the the target images
via *wic* tool.
In the very same environment yocto environment as above run:

```
wic create sdimage-bootpart -e iot-image-min
wic create sdimage-bootpart -e iot-image
wic create sdimage-bootpart -e iot-image-dev
```

According to wic all the sd-images are created at */var/tmp/wic/build*
and are named *sdimage-bootpart-<timestamp>-mmcblk.direct*
Ready to be flashed to sd card like:

```
$ # copy the image on your sd card - lets assume your sd card is /dev/sdc
$ sudo dd if=/var/tmp/wic/build/sdimage-bootpart-201901121726-mmcblk.direct of=/dev/sdc bs=1M && sync && sync
```

### Make package feed available

In the very same environment yocto environment as above run:

```
bitbake package-index
rsync -r -u --exclude 'x86_64*' tmp/deploy/ipk/* /var/www/html/repo

```
This will recreate the package index and synchronize with public running web server.
This is assuming there is a apache2 web server running that serves */var/www/html* as server root
and that there is a repo directory where the build user has write access to.
It assumes furthermore that "tmp" is set as TMPDIR variable


## Development and Release Cycles

**Note: Development cycles, ci approaches and releases differ from ordinary development approaches since we try to manifest a distribution**


### Application Build - by example

Application builds (CI builds, release builds) are targeting building the application *based on a **stable** distribution*. I.e. the meta build system (YOCTO) is just an arbitrator and delivers the SDK / build environment to build a single application.

Subject of development is the application code. The yocto application recipe is perceived as fixed environment.

A stable distribution is defined by the *master* branch of the
**yocto-ams-repo** that ultimately references the *master* branch
in the **yocto-meta-ams** meta layer repository.

In the **meta-ams** layer exist all the iot recipes at different
versions.

Let's assume the application we are up to build is named *appl*
and it is part ofthe *iot-image*:

For application builds it need to be controlled which specific
git branch/tag shall be pulled from:

| Build type | Access injection                                |
|------------|-------------------------------------------------|
| CI build   | inject RT_BRANCH = "feature/xyz"                |
| CI master  | inject nothing - master branch is default       |
| Release    | create recipe appl_x.y.z, set preferred version |

As a result, there is no need to modify
any of the branches in **yocto-ams-repo** or **yocto-meta-ams**.
but bitbake shall be invoked with respective settings for the
*appl* git based recipe:

```
$ echo RT_BRANCH=\"feature/xyz\" > appsrc-settings.conf
$ echo BPV=\"0.1.1\" >> appsrc-setting.conf
bitbake --read=appsrc-setting.conf iot-image
```


### Distro CI Build - Branches and Manifests

A distribution is more than an application and is formed by a set of
applications, middleware, libraries, arranged into multiple images and multiple packages. Subject of a distribution build is a set of
images for a set of machines and a set of packages. All that is described by a **set of recipes** and further *meta configuration* arranged in *meta-ams* layer and managed in **yocto-ams-repo** and **yocto-meta-ams** repo.

Subject of development are the recipes that form the distribution.

*CI feature builds* are configured via a manifest *feature/xyz* branch of **yocto-ams-repo**. That manifest refers to *feature/xyz* branch in **yocto-meta-ams** repo.

*CI master builds* are configured via a manifest *master* branch of **yocto-ams-repo**. That manifest refers to *master* branch in **yocto-meta-ams** repo.

Note: All other yocto repositories (like meta-oe) as requested in yocto-ams-repo are pointing to fixed SHA commits.

| Build type | Access injection via yocto-ams-repo             |
|------------|-------------------------------------------------|
| CI build   | repo checkout of  "feature/xyz"  branch         |
| CI master  | repo checkout of  "master"  branch              |
| Release    | repo checkout of  "release-branch"  branch      |

Release branches in **yocto-ams-repo"** ar necessary, since
fixing of version in yocto configurations are manifested by
stamping in **preferred** versions into the meta build specification.
These preferred version configuration are injected into commits that should not end up on the master branch but on the respective release branch.

### The disto development cycle - by example

1. create feature branch on yocto-meta-ams
2. create feature branch on yocto-ams-repo and let it point to the feature branch of yotcto-meta-ams (git)
3. work on the yocto-meta-ams feature branch (repo init ...)
4. review yocto-meta-ams feature branch and merge into master
5. remove feature branch from yocto-meta-ams (git)


### Support an application release in yocto - by example

Prerequisite: Do an appliation relase as you do for any ordinary
application that is not subject to yocto meta build.
As a result, there is a release tag *v1.2.3* on the *master* branch

1. create feature branch on yocto-meta-ams
2. create feature branch on yocto-ams-repo and let it point to the
3. work on the yocto-meta-ams feature branch (repo init ...) and create recipe named **appl_1.2.3.bb** whereby appl is the name of the application.
4. review yocto-meta-ams feature branch and merge into master
5. remove feature branch from yocto-meta-ams (git)


### Make a distro release - by example

The name of the release shall be *thud-ams* to illustrate the
steps below.

1. create *release/thud-ams* branch on yocto-meta-ams
2. create *release/thud-ams* branch on yocto-ams-repo and let it point to the *release/thud-ams* branch of yotcto-meta-ams (git)
3. work on the yocto-meta-ams *release/thud-ams* branch (repo init ...) by adding appropriate *preferred* version definitions
4. tag the yocto-meta-ams last commit of *release/thud-ams* after reviewing. The tag shall be *thud-ams*.
5. point manifest in on the yocto-ams-repo in *release/thud-ams* branch to the *thud-ams* tag of yocto-meta-ams.

The *release/thud-ams* branch will live forever.

