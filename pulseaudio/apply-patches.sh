
set -e -o pipefail

SB_PATCHDIR=${CWD}/patches

# patch -p0 -E --backup --verbose -i ${SB_PATCHDIR}/${NAME}.patch
#for patch in ${SB_PATCHDIR}/0*-*.patch ;do
  #patch -p1 -E --backup --verbose -i ${patch} || exit 1
#done

set +e +o pipefail
