# Makefile for express
#
# Copyright:   (c) 2015-2018 Rudy Matela
# License:     3-Clause BSD  (see the file LICENSE)
# Maintainer:  Rudy Matela <rudy@matela.com.br>
TESTS = \
  test/main \
  test/core \
  test/map \
  test/instances \
  test/fixtures \
  test/express \
  test/express-derive \
  test/name \
  test/name-derive \
  test/utils \
  test/canon \
  test/match \
  test/hole \
  test/fold \
  test/show \
  test/ord \
  test/listable
EGS =
BENCHS = \
  eg/u-extrapolate \
  eg/u-speculate \
  bench/compare \
  bench/pairs \
  bench/tiers \
  $(EGS)
GHCIMPORTDIRS = src:test
GHCFLAGS = -O2 $(shell grep -q "Arch Linux" /etc/lsb-release && echo -dynamic)
HADDOCKFLAGS = --no-print-missing-docs
RUNPARAMETERS =
LIB_DEPS = base template-haskell

all: mk/toplibs

all-all: mk/All.o

test: $(patsubst %,%.run,$(TESTS)) test-sdist diff-test

slow-test: RUNPARAMETERS=50400
slow-test: test

%.run: %
	./$< $(RUNPARAMETERS)

.PHONY: bench
bench: $(patsubst %,%.bench,$(BENCHS))
	@mkdir -p bench/runtime/$$HOSTNAME
	./bench/versions | tee bench/runtime/$$HOSTNAME/versions

.PHONY: %.bench
%.bench: %
	@mkdir -p bench/runtime/$$HOSTNAME/$<
	@printf "%-18s " $<
	@/usr/bin/time -f%e ./$< 2>&1 >/dev/null | tee bench/runtime/$$HOSTNAME/$<.runtime

clean: clean-hi-o clean-haddock
	rm -f $(TESTS) $(BENCHS) $(EGS) mk/toplibs

ghci: mk/All.ghci

install:
	@echo "use \`cabal install' instead"

test-sdist:
	./test/sdist

test-via-cabal:
	cabal test

test-via-stack:
	stack test

diff-test: $(patsubst %,%.diff-test,$(BENCHS))

update-diff-test: $(patsubst %,%.update-diff-test,$(BENCHS))

%.diff-test: %
	./$< | diff -rud test/model/$<.out -

%.update-diff-test: %
	./$< >           test/model/$<.out

test-via-everything: test test-via-cabal test-via-stack

legacy-test: # needs ghc-8.0 .. ghc-7.8 installed as such
	make clean  &&  make test GHC=ghc-8.2  GHCFLAGS="-Werror -dynamic"
	make clean  &&  make test GHC=ghc-8.0  GHCFLAGS="-Werror -dynamic"
	make clean  &&  make test GHC=ghc-7.10 GHCFLAGS="-Werror -dynamic"
	make clean  &&  make test GHC=ghc-7.8  GHCFLAGS="-Werror -dynamic"
	make clean  &&  make test

legacy-test-via-cabal: # needs similarly named cabal wrappers
	cabal clean  &&  cabal-ghc-8.2  configure  &&  cabal-ghc-8.2  test
	cabal clean  &&  cabal-ghc-8.0  configure  &&  cabal-ghc-8.0  test
	cabal clean  &&  cabal-ghc-7.10 configure  &&  cabal-ghc-7.10 test
	cabal clean  &&  cabal-ghc-7.8  configure  &&  cabal-ghc-7.8  test
	cabal clean  &&  cabal test

prepare:
	cabal update  &&  cabal install leancheck

prepare-legacy-test:
	cabal-ghc-8.2  update  &&  cabal-ghc-8.2  install leancheck
	cabal-ghc-8.0  update  &&  cabal-ghc-8.0  install leancheck
	cabal-ghc-7.10 update  &&  cabal-ghc-7.10 install leancheck
	cabal-ghc-7.8  update  &&  cabal-ghc-7.8  install leancheck

hlint:
	hlint \
	  --ignore "Use import/export shortcut" \
	  --ignore "Redundant bracket" \
	  .

markdown: README.html

%.html: %.md
	pandoc $< -o $@

# NOTE: (very hacky!) the following target allows parallel compilation (-jN) of
# eg and test programs so long as they don't share dependencies _not_ stored
# in src/ and test/.  Runnable binaries should depend on mk/toplibs instead of
# actual Haskell source files
mk/toplibs: mk/Toplibs.o
	touch mk/toplibs

include mk/haskell.mk
