#!/bin/bash

OS_TARGET=$1
destdir=$2

if [ -z "$OS_TARGET=" ]; then
   export OS_TARGET==win32
fi

if [ -z "$destdir" ]; then
   export destdir=/tmp/ccdciel
fi

echo Install ccdciel $OS_TARGET to $destdir

install -m 755 -d $destdir
install -m 755 -d $destdir/scripts
install -m 755 -d $destdir/scripts/siril
install -m 755 -d $destdir/data
install -m 755 -d $destdir/data/stars
install -d -m 755 $destdir/data/dso
install -m 755 -d $destdir/data/language
install -m 755 -d $destdir/doc


if [ $OS_TARGET = win32 ]; then 
  strip -v -o $destdir/ccdciel.exe src/ccdciel.exe 
  strip -v -o $destdir/libccdcielwcs.dll library/wcs/libccdcielwcs.dll
fi
if [ $OS_TARGET = win64 ]; then
  strip -v -o $destdir/ccdciel.exe src/ccdciel.exe 
  strip -v -o $destdir/libccdcielwcs.dll library/wcs/libccdcielwcs.dll
fi

install -v -m 644 scripts/scope_park.script  $destdir/scripts/scope_park.script
install -v -m 644 scripts/scope_unpark.script  $destdir/scripts/scope_unpark.script
install -v -m 644 scripts/T_ccd_temp_down.script  $destdir/scripts/T_ccd_temp_down.script
install -v -m 644 scripts/T_ccd_temp_up.script  $destdir/scripts/T_ccd_temp_up.script
install -v -m 644 scripts/T_scope_alignment.script  $destdir/scripts/T_scope_alignment.script 
install -v -m 644 scripts/T_eqmod_alignment.script  $destdir/scripts/T_eqmod_alignment.script 
install -v -m 755 scripts/astrometry.sh  $destdir/scripts/astrometry.sh
install -v -m 755 scripts/astrometry-online.sh  $destdir/scripts/astrometry-online.sh
install -v -m 755 scripts/astrometry-macos.sh  $destdir/scripts/astrometry-macos.sh
install -v -m 755 scripts/siril_bias.script  $destdir/scripts/siril_bias.script
install -v -m 755 scripts/siril_dark.script $destdir/scripts/siril_dark.script
install -v -m 755 scripts/siril_flat.script $destdir/scripts/siril_flat.script
install -v -m 755 scripts/siril_light.script $destdir/scripts/siril_light.script
install -v -m 755 scripts/siril/template_bias.ssf  $destdir/scripts/siril/template_bias.ssf
install -v -m 755 scripts/siril/template_dark.ssf  $destdir/scripts/siril/template_dark.ssf
install -v -m 755 scripts/siril/template_flat.ssf  $destdir/scripts/siril/template_flat.ssf
install -v -m 755 scripts/siril/template_light.ssf  $destdir/scripts/siril/template_light.ssf
install -v -m 644 data/stars/focus_star_4   $destdir/data/stars/focus_star_4
install -v -m 644 data/stars/focus_star_5   $destdir/data/stars/focus_star_5
install -v -m 644 data/stars/focus_star_6   $destdir/data/stars/focus_star_6
install -v -m 644 data/stars/focus_star_7   $destdir/data/stars/focus_star_7
install -v -m 644 data/stars/focus_star_8   $destdir/data/stars/focus_star_8
install -v -m 644 data/dso/deep_sky.csv  $destdir/data/dso/deep_sky.csv
install -v -m 644 data/language/ccdciel.po      $destdir/data/language/ccdciel.en.po
install -v -m 644 data/language/ccdciel.en_GB.po $destdir/data/language/ccdciel.en_GB.po
install -v -m 644 data/language/ccdciel.fr.po   $destdir/data/language/ccdciel.fr.po
install -v -m 644 data/language/ccdciel.it.po   $destdir/data/language/ccdciel.it.po
install -v -m 644 doc/doc_ccdciel_en.pdf    $destdir/doc/doc_ccdciel_en.pdf

