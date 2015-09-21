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

# Min Docker version to run flocker
MIN_DOCKER_VERSION="1.7.1"	# Previous versions should work
				# but I tested with 1.7.1 ...

# Min Vagrant version to run flocker
MIN_VAGRANT_VERSION="1.6.2"

# Min Python version to run flocker
MIN_PYTHON_VERSION="2.7"

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
    echo "		--check-virtualbox: check virtualbox is installed"
    echo "		--check-ssh: check ssh is installed"
    echo "		--check-mongo: check mongo is installed"
    echo "		--check-python: check python version"
    echo "		--check-docker: check docker version"
    exit 0
}

log() {
    test -z "$VERBOSE" || echo "->" "$@"
}

die() {
    printf >&2 "fatal: %s\n" "$@"
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
	--check-virtualbox)
	    CHECK_VIRTUALBOX=1 ;;
	--check-ssh)
	    CHECK_SSH=1 ;;
	--check-mongo)
	    CHECK_MONGO=1 ;;
	--check-python)
	    CHECK_PYTHON=1 ;;
	--check-docker)
	    CHECK_DOCKER=1 ;;
	-*)
	    die "unrecognised option: '$arg'\n$USAGE" ;;
	*)
	    die "too many arguments\n$USAGE" ;;
    esac
done

check_at_least_version() {
	MIN_VERS="$1"
	CUR_VERS="$2"
	PROG_NAME="$3"
	# Get major, minor and fix numbers for each version
	MIN_MAJ=$(expr "$MIN_VERS" : "\([^.]*\).*") || die "No major version number in '$MIN_VERS'"
	CUR_MAJ=$(expr "$CUR_VERS" : "\([^.]*\).*") || die "No major version number in '$CUR_VERS'"
	if MIN_MIN=$(expr "$MIN_VERS" : "[^.]*\.\([^.]*\).*")
	then
		MIN_FIX=$(expr "$MIN_VERS" : "[^.]*\.[^.]*\.\([^.]*\).*") || MIN_FIX="0"
	else
		MIN_MIN="0"
		MIN_FIX="0"
	fi
	if CUR_MIN=$(expr "$CUR_VERS" : "[^.]*\.\([^.]*\).*")
	then
		CUR_FIX=$(expr "$CUR_VERS" : "[^.]*\.[^.]*\.\([^.]*\).*") || CUR_FIX="0"
	else
		CUR_MIN="0"
		CUR_FIX="0"
	fi
	# Compare versions
	VERS_LEAST="$PROG_NAME version '$CUR_VERS' should be at least '$MIN_VERS'"
	test "$CUR_MAJ" -gt $(expr "$MIN_MAJ" - 1) || die "$VERS_LEAST"
	test "$CUR_MAJ" -gt "$MIN_MAJ" || {
		test "$CUR_MIN" -gt $(expr "$MIN_MIN" - 1) || die "$VERS_LEAST"
		test "$CUR_MIN" -gt "$MIN_MIN" || {
			test "$CUR_FIX" -ge "$MIN_FIX" || die "$VAG_VERS_LEAST"
		}
	}
}

if test "$CHECK_VAGRANT" = "1"
then
	log "Checking Vagrant is installed"
	type vagrant || die "Vagrant is not installed"
	VAGRANT=$(vagrant --version) || die "vagrant --version fails"
	log "Checking Vagrant version"
	VAG_VERS=$(expr "$VAGRANT" : "Vagrant \(.*\)") || die "Unknown Vagrant version '$VAGRANT'"
	check_at_least_version "$MIN_VAGRANT_VERSION" "$VAG_VERS" "Vagrant"
	echo "Vagrant version '$VAGRANT' is ok"
fi

if test "$CHECK_VIRTUALBOX" = "1"
then
	log "Checking VirtualBox is installed"
	type virtualbox || die "VirtualBox is not installed"
fi

if test "$CHECK_SSH" = "1"
then
	log "Checking ssh is installed"
	type ssh || die "ssh is not installed"
	SSH=$(ssh -V) || die "ssh -V fails"
	type ssh-agent || die "ssh-agent is not installed"
	type ssh-add || die "ssh-add is not installed"
fi

if test "$CHECK_MONGO" = "1"
then
	log "Checking Mongo is installed"
	type mongo || die "VirtualBox is not installed"
	MONGO=$(mongo --version) || die "mongo --version fails"
fi

if test "$CHECK_PYTHON" = "1"
then
	log "Checking Python is installed"
	type python || die "Python is not installed"
	PYTHON=$(python --version 2>&1) || die "python --version fails"
	log "Checking Python version"
	PY_VERS=$(expr "$PYTHON" : "Python \(.*\)") || die "Unknown Python version '$PYTHON'"
	check_at_least_version "$MIN_PYTHON_VERSION" "$PY_VERS" "Python"
	echo "Python version '$PYTHON' is ok"
fi

if test "$CHECK_DOCKER" = "1"
then
	log "Checking Docker is installed"
	type docker || die "Docker is not installed"
	DOCKER=$(docker --version) || die "docker --version fails"
	log "Checking Docker version"
	DOC_VERS=$(expr "$DOCKER" : "Docker version \(.*\),.*") || die "Unknown Docker version '$DOCKER'"
	check_at_least_version "$MIN_DOCKER_VERSION" "$DOC_VERS" "Docker"
	echo "Docker version '$DOCKER' is ok"
fi

