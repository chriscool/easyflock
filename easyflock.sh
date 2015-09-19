#!/bin/sh
#
# Copyright (c) 2015 Christian Couder
# MIT Licensed; see the LICENSE file in this repository.
#
# Script to easily install and configure Flocker.
# See https://clusterhq.com for information on Flocker.

##########
# CONFIG #
##########

# Min Vagrant version to run flocker:
MIN_VAG_MAJ=1
MIN_VAG_MIN=6
MIN_VAG_FIX=2

##########
# SCRIPT #
##########

USAGE="$0 [-h] [-v] [--check-vagrant] [--check-ssh]"

usage() {
    echo "$USAGE"
    echo "	Install and configure Flocker"
    echo "	Options:"
    echo "		-h|--help: print this usage message and exit"
    echo "		-v|--verbose: print logs of what happens"
    echo "		--check-vagrant: check vagrant version"
    echo "		--check-ssh: check ssh is installed"
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
	--check-vagrant)
	    CHECK_VAGRANT=1 ;;
	--check-ssh)
	    CHECK_SSH=1 ;;
	-*)
	    die "unrecognised option: '$arg'\n$USAGE" ;;
	*)
	    die "too many arguments\n$USAGE" ;;
    esac
done

if test "$CHECK_VAGRANT" = "1"
then
	log "Checking vagrant is installed"
	type vagrant || die "Vagrant is not installed"
	VAGRANT=$(vagrant --version) || die "vagrant --version fails"
	log "Checking vagrant version"
	VAG_VERS_LEAST="Vagrant version '$VAGRANT' should be at least $MIN_VAG_MAJ.$MIN_VAG_MIN.$MIN_VAG_FIX"
	VAG_MAJ=$(expr "$VAGRANT" : "Vagrant \([^.]*\).*") || die "Unknown Vagrant version '$VAGRANT'"
	test "$VAG_MAJ" -gt $(expr "$MIN_VAG_MAJ" - 1) || die "$VAG_VERS_LEAST"
	test "$VAG_MAJ" -gt "$MIN_VAG_MAJ" || {
		VAG_MIN=$(expr "$VAGRANT" : "Vagrant [^.]*\.\([^.]*\).*") || die "$VAG_VERS_LEAST"
		test "$VAG_MIN" -gt $(expr "$MIN_VAG_MIN" - 1) || die "$VAG_VERS_LEAST"
		test "$VAG_MIN" -gt "$MIN_VAG_MIN" || {
			VAG_FIX=$(expr "$VAGRANT" : "Vagrant [^.]*\.[^.]*\.\([^.]*\).*") || die "$VAG_VERS_LEAST"
			test "$VAG_FIX" -ge "$MIN_VAG_FIX" || die "$VAG_VERS_LEAST"
		}
	}
	echo "Vagrant version '$VAGRANT' is ok"
fi

if test "$CHECK_SSH" = "1"
then
	log "Checking ssh is installed"
	type ssh || die "ssh is not installed"
	SSH=$(ssh -V) || die "ssh -V fails"
	type ssh-agent || die "ssh-agent is not installed"
	type ssh-add || die "ssh-add is not installed"
fi
