Repo managed Yocto BSP for Riotboard
====================================

This is the Pixmeter Yocto BSP Manifest for Riotboard.

To get the BSP you need to have `repo` installed and use it as:

**Install the** `repo` **utility:**

    $: mkdir -p ~/bin
    $: curl curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
    $: chmod a+x ~/bin/repo
    $: sha1sum ~/bin/repo


**Download the BSP source:**

    $: PATH=${PATH}:~/bin
    $: mkdir pxm-riotboard-bsp
    $: cd pxm-riotboard-bsp
    $: repo init -u git@worker.pixmeter.eu:yocto.pxm-riotboard-bsp-platform.git -b daisy-next
    $: repo sync

Once this has complete, you will have all you need. To start a build, do e.g.:

    $: source ./setup-environment build
    $: bitbake core-image-minimal

You can use any directory to host your build.

The source code will be checked out at `pxm-riotboard-bsp/sources`.

Optional BB site configuration
------------------------------

The `site.conf` file is intended to provide configuration which is used by
default in the site where it is building. There are several uses as:

  * override `DL_DIR` for a company shared cache;
  * set proxy value for GIT;
  * etc...

The `setup-environment` script will handle a local copy of the `site.conf`
file which must be stored in the build users home directory either on
`$HOME/.oe/site.conf` or `$HOME/.yocto/site.conf` (prefered location).

### Example of a BB site configuration file ###

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

