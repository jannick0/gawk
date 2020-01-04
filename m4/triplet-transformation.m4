dnl AX_TRIPLET_TRANSFORMATION(SYSTEM-TYPE, SED-SCRIPT [, HEADER])
dnl with
dnl     SYSTEM-TYPE : `build', `host' or `target'
dnl     SED-SCRIPT  : valid sed script transforming the triplet in
dnl                    variable `ac_cv_<SYSTEM-TYPE>'
dnl     HEADER      : message header printed when triplet conversion
dnl                    is applied
dnl
dnl Read the triplet in the cache variable `ac_cv_<SYSTEM-TYPE>',
dnl try to convert it using the sed script SED-SCRIPT.  If the
dnl conversion resulted in a change
dnl   - backup the original triplet in the cache variable
dnl      `<PROGRAM>_cv_<SYSTEM-TYPE>_orig'
dnl   - override the converted version in `ac_cv_<SYSTEM-TYPE>'
dnl   - update the variables `<SYSTEM-TYPE>-(os|cpu|vendor)' (which is the
dnl       ultimate goal of this macro).
dnl
AC_DEFUN([AX_TRIPLET_TRANSFORMATION],
[AC_REQUIRE([AC_CONFIG_AUX_DIR_DEFAULT])dnl
AC_REQUIRE_AUX_FILE([config.sub])dnl
dnl This part should appear in the configure script AFTER the block
dnl handling the original sytem-type variables build/host/target.
AS_VAR_PUSHDEF([ax_triplet_orig],[]AC_PACKAGE_TARNAME[_cv_$1_orig])
dnl The real configure variable `ac_cv_target' might be void.
if test x$ac_cv_$1 != x; then
dnl here the transformation happens.
  ax_tt_var=`echo $ac_cv_$1 | sed '$2'`
  if test x$ax_tt_var = x; then
    AC_MSG_NOTICE([sed script: $1 triplet conversion `$ac_cv_$1' with sed script `$2'failed.])
dnl test if transformed triplet is known to config.sub, hence probably to most of the autotools.
  elif test x$ax_tt_var != x`$SHELL "$ac_aux_dir/config.sub" $ax_tt_var`; then
    AC_MSG_NOTICE([`config.sub' test: $1 triplet conversion of `$ac_cv_$1' produced invalid triplet `$ax_tt_var'.])
dnl did anything change at all?
  elif test x$ax_tt_var != x$ac_cv_$1; then
dnl print the header just once in one configure script
    m4_ifnblank([$3],[dnl
      if test x$ax_tt_header_is_printed != xyes; then
        ax_tt_header_is_printed=yes
        AC_MSG_NOTICE([$3])
      fi])
    ax_triplet_orig=$ac_cv_$1
    ac_cv_$1=$ax_tt_var
    AC_MSG_NOTICE([$1: replacing $ax_triplet_orig -> $ac_cv_$1])
dnl use of autoconf internal: rerun the triplet split cpu/vendor/host
    _AC_CANONICAL_SPLIT([$1])
  fi
  ax_tt_var=
fi
AS_VAR_POPDEF([ax_triplet_orig])dnl
])dnl AX_TRIPLET_TRANSFORMATION

dnl
dnl GAWK_CANONICAL_HOST
dnl
dnl ACTIVE FOR PLATFORM MSYS ONLY:
dnl This hackery shall fool LIBTOOL and make it believe under a MSYS
dnl platform that we are on CYGWIN which LIBTOOL(2.4.6/Dec 2019) can
dnl handle well regarding shared submodules.
dnl
dnl Call `GAWK_CANONICAL_HOST' instead of `AC_CANONICAL_HOST' high up
dnl in configure.ac.
dnl
dnl This macro works inside configure as if it was called like so:
dnl
dnl #! /usr/bin/bash
dnl  case $(uname) in
dnl   MSYS*)
dnl     test -z $mytriplet && mytriplet=$(./config.sub $(./config.guess))
dnl     ./configure --host=$(echo $mytriplet | sed 's|-msys$|-cygwin|') $*
dnl     ;;
dnl   *) ./configure $*
dnl  esac
dnl
dnl The macro calls automatically AC_CANONICAL_HOST and replaces
dnl the triplet suffix `-msys' for `build', `host' and `target'
dnl by `-cygwin' - if given.
dnl
dnl Note that with this macro every setting for CYGWIN will be applied to MSYS.
dnl It is tested for the predominant use of generating shared module libraries
dnl on MSYS.
dnl
dnl To bypass the macro call such that it should not have any effect
dnl on the configure run pass the NON-VOID variable `gawk_disable_triplet_transform'
dnl to configure. E.g.,
dnl
dnl    ./configure gawk_disable_triplet_transform=yes
dnl
dnl In this case it defaults to calling `AC_CANONICAL_HOST'.
dnl
dnl TODO remove when MSYS is supported by LIBTOOL.
dnl
AC_DEFUN_ONCE([GAWK_CANONICAL_HOST],
[AC_BEFORE([$0],[AC_CANONICAL_BUILD])dnl
AC_BEFORE([$0],[AC_CANONICAL_HOST])dnl
m4_define([GAWK_TT_SEDSCRIPT],[s|-msys$|-cygwin|])dnl
m4_define([GAWK_TT_HEADER],[Triplet conversion on MSYS platform:])
ax_tt_header_is_printed=:
dnl skip case statement if gawk_disable_triplet_transform is set to
dnl any non-void string.
AS_CASE([x$gawk_disable_triplet_transform/`uname`],[x/MSYS*],
  [m4_foreach_w(_sys_type,[build host target],
    [AX_TRIPLET_TRANSFORMATION(_sys_type,[GAWK_TT_SEDSCRIPT],[GAWK_TT_HEADER])])
AC_CANONICAL_HOST
])])dnl GAWK_CANONICAL_HOST
