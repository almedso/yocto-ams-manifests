#!/usr/bin/env bash

help () {
    cat <<EOHELP
$0 [--help|--list|--current] CONFIG

Activate a build context configuration from configs folder by sym-linking it
into projects root directory.

CONFIG:
    Name of the build context to select

Options:
--help:
    Shows this text
--list:
    Lists the available build context (content configs folder)
--current:
    Shows which build context is currently selected (not implemented yet)

A configuration is composed of the following files:

$CONFIG_FILES

EOHELP
}

[ "$DEBUG" == 'true' ] && set -x  # aka set -o xtrace
set -o pipefail
set -o errexit  # aka set -e

CURRENT_DIR=$(pwd)

# Cleanup and exit - shall be called last from the script
#
# Args:
#   $1 exit code the script will return
cleanup_and_exit () {
    cd $CURRENT_DIR
    set +x

    # good habit: clean up vars even if not neccessary
    unset CURRENT_DIR
    unset CONFIG_FILES

    exit ${1:-0}
}


initialize_vars () {
    CONFIG_FILES="site.conf ronto.yml docker-compose.yml"
}


unlink_config () {
    for conf_file in $CONFIG_FILES ; do
        rm -f $conf_file
    done
}

# Link current configuration
#
# Prerequisite, previous configuration is unlinked
#
# Args:
#   $1: directory containing the configuration to link
link_config () {
    for conf_file in $CONFIG_FILES ; do
        if [ -f configs/$1/$conf_file ]; then
            echo "LINKING: $conf_file"
            ln -s configs/$1/$conf_file $conf_file
        fi
    done
}

main () {
    trap cleanup_and_exit INT TERM
    initialize_vars
    case ${1} in
    --list)
        echo "Available configurations are:"
        echo "$(ls configs)"
        echo ""
        cleanup_and_exit
        ;;
    --current)
        echo "Currently selected build context: Not implemented yet"
        echo "check with ls -lisa and inspect where the symlinks link to"
        cleanup_and_exit 1
        ;;
    --help|-?|help)
        help
        cleanup_and_exit 1
        ;;
    esac
    unlink_config
    link_config "$@"
    cleanup_and_exit
}

main "$@"




