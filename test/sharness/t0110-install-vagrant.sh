#!/bin/sh

test_description="Test --install-vagrant"

. lib/test-lib.sh

test_expect_success "start a docker container" '
	DOCID=$(start_docker)
'

test_expect_success "install vagrant inside the container" '
	exec_docker "$DOCID" "/mnt/easyflock.sh -v --install-vagrant"
'

test_expect_success "check that vagrant is installed" '
	exec_docker "$DOCID" "vagrant --version" >actual &&
	egrep "^Vagrant" actual
'

test_expect_success "check that we have the good vagrant" '
	exec_docker "$DOCID" "/mnt/easyflock.sh -v --check-vagrant"
'

test_expect_success "stop a docker container" '
	stop_docker "$DOCID"
'

test_done
