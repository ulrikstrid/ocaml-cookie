#!/bin/sh

NAME="$1"
TAG="$2"

if [ -z "$NAME" || -z "$TAG" ]; then
  printf "Usage: ./dune-release.sh <library-name> <tag-name>\n"
  printf "Please make sure that dune-release is available.\n"
  exit 1
fi

step()
{
  printf "Continue? [Yn] "
  read action
  if [ "x$action" == "xn" ]; then exit 2; fi
  if [ "x$action" == "xN" ]; then exit 2; fi
}

dune-release tag "$TAG"
step
dune-release distrib -p "$NAME" -n "$NAME" -t "$TAG" --skip-tests #--skip-lint
step
dune-release publish distrib -p "$NAME" -n "$NAME" -t "$TAG"
step
dune-release opam pkg -p "$NAME" -n "$NAME" -t "$TAG"
step
dune-release opam submit -p "$NAME" -n "$NAME" -t "$TAG"
