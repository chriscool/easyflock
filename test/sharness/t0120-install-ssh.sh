#!/bin/sh

test_description="Test --install-ssh"

. lib/test-lib.sh

test_expect_success "start a docker container" '
	DOCID=$(start_docker)
'

test_expect_success "install ssh inside the container" '
	exec_docker "$DOCID" "/mnt/easyflock.sh -v --install-ssh"
'

test_expect_success "check that ssh is installed" '
	exec_docker "$DOCID" "ssh -V 2>&1" >actual &&
	egrep "^OpenSSH" actual
'

test_expect_success "check that we have the good ssh" '
	exec_docker "$DOCID" "/mnt/easyflock.sh -v --check-ssh"
'

test_expect_success "stop a docker container" '
	stop_docker "$DOCID"
'

test_done
