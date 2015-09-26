#!/bin/sh

test_description="Basic Docker Tests"

. lib/test-lib.sh

test_expect_success "start a docker container" '
	DOCID=$(start_docker)
'

test_expect_success "exec a command in docker container" '
	exec_docker "$DOCID" "echo \"Hello world!\"" >actual
'

test_expect_success "command output looks good" '
	echo "Hello world!" >expected &&
	test_cmp expected actual
'

test_expect_success "stop a docker container" '
	stop_docker "$DOCID"
'

test_done
