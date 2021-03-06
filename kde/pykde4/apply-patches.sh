
set -e -o pipefail

SB_PATCHDIR=${CWD}/patches

# patch -p0 -E --backup --verbose -i ${SB_PATCHDIR}/${NAME}.patch
patch -p1 -E --backup --verbose -i ${SB_PATCHDIR}/pykde4-4.9.90-respect_sip_flags.patch
patch -p1 -E --backup --verbose -i ${SB_PATCHDIR}/fix_kpythonpluginfactory_build.diff

set +e +o pipefail
