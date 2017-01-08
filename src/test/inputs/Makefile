SHELL = /bin/bash

include ../../../Makefrag

TEST_IHEX_FILES = $(addsuffix .ihex,$(RV32_TESTS))

default: $(TEST_IHEX_FILES)

%.ihex:
	riscv64-unknown-elf-objcopy -O ihex  /opt/riscv/target/share/riscv-tests/isa/$* $@
