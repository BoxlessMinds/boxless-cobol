# COBOL playground build - run inside WSL (or via .\build.ps1 on Windows).
#
#   make            build library modules, tutorials and examples
#   make lib        build lib/src/*.cob into build/lib/*.so
#   make test       build and run every lib/tests/TEST-*.cob
#   make run NAME=tutorials/01-hello/hello.cob
#                   build one program and run it from its own folder
#   make clean      remove build/

COBC     ?= cobc
COBFLAGS ?= -Wall -I lib/copybooks

BUILD  := build
BIN    := $(BUILD)/bin
LIBDIR := $(BUILD)/lib

LIB_SRC   := $(wildcard lib/src/*.cob)
TUT_SRC   := $(wildcard tutorials/*/*.cob)
EX_SRC    := $(wildcard examples/*/*.cob)
TEST_SRC  := $(wildcard lib/tests/*.cob)
COPYBOOKS := $(wildcard lib/copybooks/*.cpy)

# build/bin/<basename> for each source given
bin_of = $(addprefix $(BIN)/,$(notdir $(basename $(1))))

LIB_MODS  := $(patsubst lib/src/%.cob,$(LIBDIR)/%.so,$(LIB_SRC))
TUT_BINS  := $(call bin_of,$(TUT_SRC))
EX_BINS   := $(call bin_of,$(EX_SRC))
TEST_BINS := $(call bin_of,$(TEST_SRC))

# Main programs live in several folders; let make find them.
vpath %.cob $(sort $(dir $(TUT_SRC) $(EX_SRC) $(TEST_SRC)))

export COB_LIBRARY_PATH := $(CURDIR)/$(LIBDIR)

.PHONY: all lib tutorials examples tests test run clean help

all: lib tutorials examples tests

lib: $(LIB_MODS)
tutorials: $(TUT_BINS)
examples: $(EX_BINS)
tests: $(TEST_BINS)

$(LIBDIR)/%.so: lib/src/%.cob $(COPYBOOKS) | $(LIBDIR)
	$(COBC) -m $(COBFLAGS) -o $@ $<

$(BIN)/%: %.cob $(COPYBOOKS) | $(BIN)
	$(COBC) -x $(COBFLAGS) -o $@ $<

$(BIN) $(LIBDIR):
	mkdir -p $@

test: lib tests
	@fail=0; for t in $(TEST_BINS); do \
	  echo "== $$t"; ./$$t || fail=1; \
	done; \
	if [ $$fail -eq 0 ]; then echo "ALL TESTS PASSED"; \
	else echo "SOME TESTS FAILED"; fi; exit $$fail

run: lib
ifeq ($(strip $(NAME)),)
	$(error usage: make run NAME=path/to/program.cob)
endif
	@$(MAKE) --no-print-directory $(call bin_of,$(NAME))
	@cd $(dir $(NAME)) && $(CURDIR)/$(call bin_of,$(NAME))

clean:
	rm -rf $(BUILD)

help:
	@sed -n '1,10p' Makefile
