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
    echo "		--check-all: check everything"
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
	--check-all)
	    CHECK_ALL=1 ;;
	--install-vagrant)
	    INSTALL_VAGRANT=1 ;;
	--install-virtualbox)
	    INSTALL_VIRTUALBOX=1 ;;
	--install-ssh)
	    INSTALL_SSH=1 ;;
	--install-mongo)
	    INSTALL_MONGO=1 ;;
	--install-python)
	    INSTALL_PYTHON=1 ;;
	--install-docker)
	    INSTALL_DOCKER=1 ;;
	--install-all)
	    INSTALL_ALL=1 ;;
	-*)
	    die "unrecognised option: '$arg'\n$USAGE" ;;
	*)
	    die "too many arguments\n$USAGE" ;;
    esac
done

major_number() {
    vers="$1"

    # Hack around 'expr' exiting with code 1 when it outputs 0
    case "$vers" in
        0) echo "0" ;;
        0.*) echo "0" ;;
        *) expr "$vers" : "\([^.]*\).*" || return 1
    esac
}

check_at_least_version() {
	MIN_VERS="$1"
	CUR_VERS="$2"
	PROG_NAME="$3"
	# Get major, minor and fix numbers for each version
	MIN_MAJ=$(major_number "$MIN_VERS") || die "No major version number in '$MIN_VERS'"
	CUR_MAJ=$(major_number "$CUR_VERS") || die "No major version number in '$CUR_VERS'"
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
			test "$CUR_FIX" -ge "$MIN_FIX" || die "$VERS_LEAST"
		}
	}
}

check_installed_version() {
	name="$1"
	bin="$2"
	cmd="$3"
	reg="$4"
	vers="$5"

	log "Checking $name is installed"
	type $bin || die "$name is not installed"
	VERS_STR=$($cmd 2>&1) || die "$cmd fails"
	log "Checking $name version"
	VERS_NUM=$(expr "$VERS_STR" : "$reg") || die "Unknown $name version '$VERS_STR'"
	check_at_least_version "$vers" "$VERS_NUM" "$name"
	echo "$name version '$VERS_STR' is ok"
}

check_VAGRANT() {
	check_installed_version "Vagrant" "vagrant" "vagrant --version" \
				"Vagrant \(.*\)" "$MIN_VAGRANT_VERSION"
}

check_VIRTUALBOX() {
	log "Checking VirtualBox is installed"
	type virtualbox || die "VirtualBox is not installed"
}

check_SSH() {
	log "Checking ssh is installed"
	type ssh || die "ssh is not installed"
	SSH=$(ssh -V) || die "ssh -V fails"
	type ssh-agent || die "ssh-agent is not installed"
	type ssh-add || die "ssh-add is not installed"
}

check_MONGO() {
	log "Checking Mongo is installed"
	type mongo || die "VirtualBox is not installed"
	MONGO=$(mongo --version) || die "mongo --version fails"
}

check_PYTHON() {
	check_installed_version "Python" "python" "python --version" \
				"Python \(.*\)" "$MIN_PYTHON_VERSION"
}

check_DOCKER() {
	check_installed_version "Docker" "docker" "docker --version" \
				"Docker version \(.*\),.*" "$MIN_DOCKER_VERSION"
}

# Perform checks
for app in "VAGRANT" "VIRTUALBOX" "SSH" "MONGO" "PYTHON" "DOCKER"
do
	var="CHECK_$app"
	eval value=\$$var
	if test "$value" = "1" || test "$CHECK_ALL" = "1"
	then
		func="check_$app"
		eval $func
	fi
done

check_file_line() {
	test -f "$1" || return
	egrep "^$2" "$1" >/dev/null || return
	egrep "^$2" "$1" | sed -e "s/^$2//"
}

# For now only distrib with /etc/os-release, /etc/lsb-release
# or lsb_release are supported.

find_distrib() {
	check_file_line "/etc/os-release" "ID=" ||
	check_file_line "/etc/lsb-release" "DISTRIB_ID=" ||
	lsb_release -i -s
}

DISTRIB=$(find_distrib) ||
die "unknown linux distrib!" "sorry, your distrib might not be supported for now!"
DISTRIB=$(echo "$DISTRIB" | tr [A-Z] [a-z])

init_aptget() {
	echo "n" | apt-get update ||
	die "'apt-get update' failed!"
}

init_package_system() {
	test "$INIT_PACKAGES_DONE" = 1 && return
	log "Initializing package system"
	case "$DISTRIB" in
	    debian|ubuntu) init_aptget ;;
	    *) die "sorry, your distrib is not be supported for now!" ;;
	esac
	INIT_PACKAGES_DONE=1
}

aptget_install() {
	apt-get install -y "$1" ||
	die "'apt-get install $1' failed!"
}

install_package() {
	log "Installing package '$1'"
	case "$DISTRIB" in
	    debian|ubuntu) aptget_install "$1" ;;
	    *) die "sorry, your distrib is not be supported for now!" ;;
	esac
}

install_VAGRANT() {
	init_package_system &&
	install_package "vagrant"
}

install_VIRTUALBOX() {
	init_package_system &&
	install_package "virtualbox"
}

install_SSH() {
	init_package_system &&
	install_package "ssh"
}

install_MONGO() {
	init_package_system &&
	install_package "mongodb-clients"
}

install_PYTHON() {
	init_package_system &&
	install_package "python"
}

install_DOCKER() {
	init_package_system &&
	install_package "docker"
}

# Perform installs
for app in "VAGRANT" "VIRTUALBOX" "SSH" "MONGO" "PYTHON" "DOCKER"
do
	var="INSTALL_$app"
	eval value=\$$var
	if test "$value" = "1" || test "$INSTALL_ALL" = "1"
	then
		func="install_$app"
		eval $func
	fi
done

