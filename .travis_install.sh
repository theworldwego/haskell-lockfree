#!/bin/bash

set -xe

if [ "$STACKVER" == "" ]; then
# Legacy cabal version; soon to be deprecated:

    cabal --version
    echo "$(ghc --version) [$(ghc --print-project-git-commit-id 2> /dev/null || echo '?')]"
    which -a ghc
    ghc --version

    cabal update # Can put a retry here...

    # This is a hack to make Travis happy because it doesn't install happy/alex by default
    # cabal install -j happy alex

    # And now we install the main packages:
    PKGS="./atomic-primops ./atomic-primops-foreign ./abstract-deque/ ./abstract-deque-tests/ ./lockfree-queue/ ./chaselev-deque/ ./mega-deque"
    cabal install -j $PKGS

    # Now enable benchmarks and tests and add the extra dependencies:
    cabal install -j --only-dependencies --enable-tests --enable-benchmarks $PKGS
else
    cat stack.yaml | grep -v resolver > stack-${STACK_RESOLVER}.yaml
    echo "resolver: ${STACK_RESOLVER}" >> stack-${STACK_RESOLVER}.yaml

    # Sweet and simple:
    stack --stack-yaml=stack-${STACK_RESOLVER}.yaml setup --no-terminal
    stack --stack-yaml=stack-${STACK_RESOLVER}.yaml test --only-snapshot --no-terminal
fi
