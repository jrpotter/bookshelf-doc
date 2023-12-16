#!/usr/bin/env bash

if ! command -v pdflatex > /dev/null; then
  >&2 echo 'pdflatex was not found in the current $PATH.'
  exit 1
fi

SRC_DIR="$1"
BUILD_DIR="$2"

cd "$SRC_DIR" || { >&2 echo "Could not cd to $SRC_DIR"; exit 1; }

# We run this command twice to allow any cross-references to resolve correctly.
# https://tex.stackexchange.com/questions/41539/does-hyperref-work-between-two-files
TEX_FILES=$(find . -name "*.tex" -not -path "*preamble.tex")
for _ in {1..2}; do
  for f in $TEX_FILES; do
    REL_DIR=$(dirname "$f")
    REL_BASE=$(basename -s ".tex" "$f")
    mkdir -p "$BUILD_DIR/doc/$REL_DIR"
    (cd "$REL_DIR" && pdflatex "$REL_BASE.tex")
    cp "$REL_DIR/$REL_BASE.pdf" "$BUILD_DIR/doc/$REL_DIR/"
  done
done
