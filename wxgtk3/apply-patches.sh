
set -e -o pipefail

SB_PATCHDIR=${CWD}/patches

# patch -p0 -E --backup --verbose -i ${SB_PATCHDIR}/${NAME}.patch
# Adapted from Gentoo
patch -p1 -E --backup --verbose -i ${SB_PATCHDIR}/wxGTK-3.0.0-collision.patch

set +e +o pipefail
