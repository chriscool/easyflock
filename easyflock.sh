#!/bin/sh
#
# Copyright (c) 2015 Christian Couder
# MIT Licensed; see the LICENSE file in this repository.
#
# Script to easily install and configure Flocker.
# See https://clusterhq.com for information on Flocker.

USAGE="$0 [-h] [-v]"

usage() {
    echo "$USAGE"
    echo "	Install and configure Flocker"
    echo "	Options:"
    echo "		-h|--help: print this usage message and exit"
    echo "		-v|--verbose: print logs of what happens"
    exit 0
}

log() {
    test -z "$VERBOSE" || echo "->" "$@"
}

die() {
    echo >&2 "fatal: $@"
    exit 1
}

# get user options
while [ "$#" -gt "0" ]; do
    # get options
    arg="$1"
    shift

    case "$arg" in
	-h|--help)
	    usage ;;
	-v|--verbose)
	    VERBOSE=1 ;;
	-*)
	    die "unrecognised option: '$arg'\n$USAGE" ;;
	*)
	    die "too many arguments\n$USAGE" ;;
    esac
done

