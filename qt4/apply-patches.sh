#!/bin/sh

set -e -o pipefail

SB_PATCHDIR=${CWD}/patches

# Set to test (some patches require others, so, is not 100%)
DRYRUN=${DRYRUN:-NO}

if [ "${DRYRUN}" = "YES" ] ; then
  DRYRUN_OPT="--dry-run"
fi

if [ "${VERBOSE}" = "YES" ] ; then
  VERBOSE_OPT="--verbose"
fi

if [ "${SVERBOSE}" = "YES" ] ; then
  set -o xtrace
fi

PATCHCOM="patch ${DRYRUN_OPT} -p1 -F1 -s ${VERBOSE_OPT}"

ApplyPatch() {
  local patch=$1
  shift
  if [ ! -f ${SB_PATCHDIR}/${patch} ]; then
    exit 1
  fi
  echo "Applying ${patch}"
  case "${patch}" in
  *.bz2) bzcat "${SB_PATCHDIR}/${patch}" | ${PATCHCOM} ${1+"$@"} ;;
  *.gz) zcat "${SB_PATCHDIR}/${patch}" | ${PATCHCOM} ${1+"$@"} ;;
  *) ${PATCHCOM} ${1+"$@"} -i "${SB_PATCHDIR}/${patch}" ;;
  esac
}

IgnorePatch() {
  if [ -n "{IGNORE}" ] ;then
    for patchnumber in ${IGNORE} ;do
      sed -e "/^${patchnumber}/d" -i $1
    done
  fi
}

# patch -p0 -E --backup --verbose ${SB_PATCHDIR}/${NAME}.patch
# don't use -b on mkspec files, else they get installed too.
ApplyPatch qt-everywhere-opensource-src-4.8.0-tp-multilib-optflags.patch -z .multilib-optflags
rm -fv mkspecs/linux-g++*/qmake.conf.multilib-optflags
# get rid of timestamp which causes multilib problem
ApplyPatch qt-everywhere-opensource-src-4.8.5-uic_multilib.patch

# reduce debuginfo in qtwebkit (webcore)
ApplyPatch qt-everywhere-opensource-src-4.8.5-webcore_debuginfo.patch

# cups16 printer discovery
ApplyPatch qt-cupsEnumDests.patch

# enable ft lcdfilter
ApplyPatch qt-x11-opensource-src-4.5.1-enable_ft_lcdfilter.patch.gz
ApplyPatch qt-everywhere-opensource-src-4.7.0-beta2-phonon_servicesfile.patch 

# may be upstreamable, not sure yet
# workaround for gdal/grass crashers wrt glib_eventloop null deref's
ApplyPatch qt-everywhere-opensource-src-4.6.3-glib_eventloop_nullcheck.patch
# hack out largely useless (to users) warnings about qdbusconnection
# (often in kde apps), keep an eye on https://git.reviewboard.kde.org/r/103699/
ApplyPatch qt-everywhere-opensource-src-4.8.3-qdbusconnection_no_debug.patch
# lrelease-qt4 tries to run qmake not qmake-qt4 (http://bugzilla.redhat.com/820767)
ApplyPatch qt-everywhere-opensource-src-4.8.1-linguist_qmake-qt4.patch
# enable debuginfo in libQt3Support
ApplyPatch qt-everywhere-opensource-src-4.8.1-qt3support_debuginfo.patch
# kde4/multilib QT_PLUGIN_PATH
ApplyPatch qt-everywhere-opensource-src-4.8.5-qt_plugin_path.patch

## upstreamable bits
# add support for pkgconfig's Requires.private to qmake
ApplyPatch qt-everywhere-opensource-src-4.8.4-qmake_pkgconfig_requires_private.patch
# fix invalid inline assembly in qatomic_{i386,x86_64}.h (de)ref implementations
# should fix the reference counting in qt_toX11Pixmap and thus the Kolourpaint
# crash with Qt 4.5
ApplyPatch qt-x11-opensource-src-4.5.0-fix-qatomic-inline-asm.patch.gz
# fix invalid assumptions about mysql_config --libs
# http://bugzilla.redhat.com/440673
ApplyPatch qt-everywhere-opensource-src-4.7.0-beta2-mysql_config.patch
# http://bugs.kde.org/show_bug.cgi?id=180051#c22
ApplyPatch qt-everywhere-opensource-src-4.6.2-cups.patch.gz

# qtwebkit to search nspluginwrapper paths too
ApplyPatch qt-everywhere-opensource-src-4.7.0-beta1-qtwebkit_pluginpath.patch

# Fails to create debug build of Qt projects on mingw (rhbz#653674)
ApplyPatch qt-everywhere-opensource-src-4.8.5-QTBUG-14467.patch

# fix QTreeView crash triggered by KPackageKit (patch by David Faure)
ApplyPatch qt-everywhere-opensource-src-4.8.0-tp-qtreeview-kpackagekit-crash.patch

# https://bugs.webkit.org/show_bug.cgi?id=63941
# -Wall + -Werror = fail
ApplyPatch qt-everywhere-opensource-src-4.8.3-no_Werror.patch

# revert qlist.h commit that seems to induce crashes in qDeleteAll<QList (QTBUG-22037)
ApplyPatch qt-everywhere-opensource-src-4.8.0-QTBUG-22037.patch

# Buttons in Qt applications not clickable when run under gnome-shell (#742658, QTBUG-21900)
ApplyPatch qt-everywhere-opensource-src-4.8.5-QTBUG-21900.patch

# workaround
# sql/drivers/tds/qsql_tds.cpp:341:49: warning: dereferencing type-punned pointer will break strict-aliasing rules [-Wstrict-aliasing]
ApplyPatch qt-everywhere-opensource-src-4.8.5-tds_no_strict_aliasing.patch
# don't spam if libicu is not present at runtime
ApplyPatch qt-everywhere-opensource-src-4.8.3-icu_no_debug.patch
# gcc doesn't support flag -fuse-ld=gold
ApplyPatch qt-everywhere-opensource-src-4.8.0-ld-gold.patch
# https://bugzilla.redhat.com/show_bug.cgi?id=810500
ApplyPatch qt-everywhere-opensource-src-4.8.2--assistant-crash.patch
# https://bugzilla.redhat.com/show_bug.cgi?id=694385
# https://bugs.kde.org/show_bug.cgi?id=249217
# https://bugreports.qt-project.org/browse/QTBUG-4862
# QDir::homePath() should account for an empty HOME environment variable on X11
ApplyPatch qt-everywhere-opensource-src-4.8.5-QTBUG-4862.patch

# poll support
ApplyPatch qt-4.8-poll.patch

## upstream patches
# adds debug support to webkit/JavaScriptCore
# UPSTREAM ME
ApplyPatch qt-everywhere-opensource-src-4.7.1-webkit_debug_javascriptcore.patch
# http://codereview.qt-project.org/#change,22006
ApplyPatch qt-everywhere-opensource-src-4.8.1-qtgahandle.patch
# backported from Qt5 (essentially)
# http://bugzilla.redhat.com/702493
# https://bugreports.qt-project.org/browse/QTBUG-5545
ApplyPatch qt-everywhere-opensource-src-4.8.5-qgtkstyle_disable_gtk_theme_check.patch
# revert fix for QTBUG-15319, fixes regression QTBUG-32908
# http://bugzilla.redhat.com/968367
# https://bugreports.qt-project.org/browse/QTBUG-32908
ApplyPatch QTBUG-15319-fix-shortcuts-with-secondary-Xkb-layout.patch -R
# workaround for MOC issues with Boost headers (#756395,QTBUG-22829)
ApplyPatch qt-everywhere-opensource-src-4.8.5-QTBUG-22829.patch


# security patches

set +e +o pipefail
