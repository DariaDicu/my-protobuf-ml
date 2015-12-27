#!/usr/bin/env sh
#
# Regenerates configure script (using autoconf).

set -ex

mkdir -p m4
autoreconf -f -i -Wall
rm -rf autom4te.cache configure.ac~ config.h.in~
