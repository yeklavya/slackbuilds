
set -e -o pipefail

SB_PATCHDIR=${CWD}/patches

# patch -p1 -E --backup --verbose -i ${SB_PATCHDIR}/${NAME}.patch
# don't strip
zcat ${SB_PATCHDIR}/sudo-1.6.7p5-strip.patch.gz | patch -p1 -E --backup --verbose
# configure.in fix
zcat ${SB_PATCHDIR}/sudo-1.7.2p1-envdebug.patch.gz | patch -p1 -E --backup --verbose
# Don't accept invalid number in uid/gid specifications
patch -p1 -E --backup --verbose -i ${SB_PATCHDIR}/sudo-1.8.8-strictuidgid.patch
# Fix several issues found by the clang static analyzer
patch -p1 -E --backup --verbose -i ${SB_PATCHDIR}/sudo-1.8.8-clangbugs.patch

set +e +o pipefail
