
set -e -o pipefail

SB_PATCHDIR=${CWD}/patches

# patch -p0 -E --backup --verbose -i ${SB_PATCHDIR}/${NAME}.patch
zcat ${SB_PATCHDIR}/${NAME}-CVE-2007-6061.patch.gz | patch -p0 -E --backup --verbose

sed -e "s|__RPM_LIBDIR__|/usr/lib${LIBDIRSUFFIX}|g" \
  ${SB_PATCHDIR}/${NAME}-1.3.9-libdir.patch | patch -p1 -E --backup --verbose

# Debian
patch -p1 -E --backup --verbose -i ${SB_PATCHDIR}/disable-dynamic-ffmpeg.patch
patch -p1 -E --backup --verbose -i ${SB_PATCHDIR}/disable-dynamic-lame.patch

set +e +o pipefail
