#!/bin/bash

set -e

module=mplayer
snaproot="svn://svn.mplayerhq.hu/${module}/trunk"

tmp=$(mktemp -d)

trap cleanup EXIT
cleanup() {
  set +e
  [ -z "${tmp}" -o ! -d "${tmp}" ] || rm -rf "${tmp}"
}

unset CDPATH
pwd=$(pwd)
snap=${snap:-$(date +%Y%m%d)}

# Export to YES to checkout the latest revision
[ "${SB_SNAPUP}" = "YES" ] || SNAP_COOPTS="-r {$snap}"

pushd "${tmp}"
  svn checkout ${SNAP_COOPTS} ${snaproot} ${module}-${snap}
  pushd ${module}-${snap}
    # Force revision number
    SVNREV="$(LC_ALL=C svn info 2> /dev/null | grep Revision | cut -d' ' -f2)"
    sed -i -e "/^svn_revision=/s|=.*|=${SVNREV}|g" ./version.sh
    find . -type d -name .svn -print0 | xargs -0r rm -rf
    sed -i -e '/^\.PHONY: version\.h$/d' Makefile
  popd
  tar -jcf "${pwd}"/${module}-${snap}.tar.bz2 ${module}-${snap}
popd >/dev/null
