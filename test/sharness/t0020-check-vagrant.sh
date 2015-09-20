#!/bin/sh

test_description="Test --check-vagrant"

. lib/test-lib.sh

test_expect_success "PATH setup" '
	mkdir bin &&
	export PATH=bin:../../..:$PATH
'

create_fake_vagrant() {
	echo "#!/bin/sh" >bin/vagrant &&
	echo "echo Vagrant $1" >>bin/vagrant &&
	chmod +x bin/vagrant
}

test_expect_success "setup fake vagrant" '
	create_fake_vagrant "3.4.5"
'

test_expect_success "fake vagrant output looks good" '
	vagrant >actual &&
	grep "3.4.5" actual
'

test_expect_success "--check-vagrant works" '
	easyflock.sh --check-vagrant
'

test_expect_success "current minimum version passes" '
	create_fake_vagrant "1.6.2" &&
	easyflock.sh --check-vagrant
'

test_expect_success "before current minimum version does not pass" '
	create_fake_vagrant "1.6.1" &&
	test_must_fail easyflock.sh --check-vagrant
'

test_expect_success "misc big versions pass" '
	create_fake_vagrant "2" &&
	easyflock.sh --check-vagrant &&
	create_fake_vagrant "1.9" &&
	easyflock.sh --check-vagrant &&
	create_fake_vagrant "1.10.2" &&
	easyflock.sh --check-vagrant &&
	create_fake_vagrant "4.1.2.3" &&
	easyflock.sh --check-vagrant &&
	create_fake_vagrant "10" &&
	easyflock.sh --check-vagrant
'

test_expect_success "misc small versions do not pass" '
	create_fake_vagrant "1" &&
	test_must_fail easyflock.sh --check-vagrant &&
	create_fake_vagrant "0.9" &&
	test_must_fail easyflock.sh --check-vagrant &&
	create_fake_vagrant "0.10.80" &&
	test_must_fail easyflock.sh --check-vagrant &&
	create_fake_vagrant "1.1.9.7" &&
	test_must_fail easyflock.sh --check-vagrant &&
	create_fake_vagrant "0" &&
	test_must_fail easyflock.sh --check-vagrant
'

test_done
