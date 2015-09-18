#!/bin/sh

test_description="Test --help"

. ./lib/sharness/sharness.sh

export PATH=../../..:$PATH

test_expect_success "--help works" '
	easyflock.sh --help >actual
'

test_expect_success "--help output looks good" '
	grep "Install and configure Flocker" actual
'

test_done
