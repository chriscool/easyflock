# Test framework for easyflock
#
# Copyright (c) 2015 Christian Couder
# MIT Licensed; see the LICENSE file in this repository.
#
# We are using Sharness (https://github.com/mlafeldt/sharness)
# which was extracted from the Git test framework.

SHARNESS_LIB="lib/sharness/sharness.sh"

. "$SHARNESS_LIB" || {
	echo >&2 "Cannot source: $SHARNESS_LIB"
	echo >&2 "Please check Sharness installation."
	exit 1
}

# Please put easyflock specific shell functions and variables below

DEFAULT_DOCKER_IMG="debian"
DOCKER_IMG="$DEFAULT_DOCKER_IMG"

TEST_TRASH_DIR=$(pwd)
TEST_SCRIPTS_DIR=$(dirname "$TEST_TRASH_DIR")
TEST_ROOT_DIR=$(dirname "$TEST_SCRIPTS_DIR")
APP_ROOT_DIR=$(dirname "$TEST_ROOT_DIR")

# This writes a docker ID on stdout
start_docker() {
	docker run -it -d -v "$APP_ROOT_DIR:/mnt" "$DOCKER_IMG" /bin/bash
}

# This takes a docker ID and a command as arguments
exec_docker() {
	docker exec -i "$1" /bin/bash -c "$2"
}

# This takes a docker ID as argument
stop_docker() {
	docker stop "$1"
}
