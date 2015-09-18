

all:
	# no-op. try:
	#   make test

test:
	cd test/sharness/ && make

.PHONY: all test
