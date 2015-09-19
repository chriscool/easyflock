#!/bin/sh

test_description="Test --check-vagrant"

. ./lib/sharness/sharness.sh


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

test_done
