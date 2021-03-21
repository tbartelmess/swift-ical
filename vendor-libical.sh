#! /usr/bin/env bash
set -x
set -e

rm -rf Sources/CLibical/*
mkdir -p Sources/CLibical/include
find  libical/src/libical -type f -name '*.c' -exec cp {} Sources/CLibical \;
find  libical/src/libical -type f -name '*.h' -exec cp {} Sources/CLibical/include \;
rm -rf Sources/CLibical/include/*_cxx.h
cp -r libical-build/* Sources/CLibical/include/
perl -I libical/scripts libical/scripts/mkderivedproperties.pl \
      -i libical/src/libical/icalderivedproperty.h.in\
      -h libical/design-data/properties.csv\
      libical/design-data/value-types.csv > Sources/CLibical/include/icalderivedproperty.h

perl -I libical/scripts libical/scripts/mkderivedproperties.pl \
      -i libical/src/libical/icalderivedproperty.c.in\
      -c libical/design-data/properties.csv\
      libical/design-data/value-types.csv > Sources/CLibical/icalderivedproperty.c

perl -I libical/scripts libical/scripts/mkderivedparameters.pl \
     -i libical/src/libical/icalderivedparameter.h.in\
     -h libical/design-data/parameters.csv > Sources/CLibical/include/icalderivedparameter.h

perl -I libical/scripts libical/scripts/mkderivedparameters.pl \
     -i libical/src/libical/icalderivedparameter.c.in\
     -c libical/design-data/parameters.csv > Sources/CLibical/icalderivedparameter.c

perl -I libical/scripts libical/scripts/mkderivedvalues.pl \
     -i libical/src/libical/icalderivedvalue.h.in\
     -h libical/design-data/value-types.csv > Sources/CLibical/include/icalderivedvalue.h

perl -I libical/scripts libical/scripts/mkderivedvalues.pl \
     -i libical/src/libical/icalderivedvalue.c.in\
     -c libical/design-data/value-types.csv > Sources/CLibical/icalderivedvalue.c

perl -I libical/scripts libical/scripts/mkrestrictiontable.pl \
     -i libical/src/libical/icalrestriction.c.in \
     libical/design-data/restrictions.csv > Sources/CLibical/icalrestriction.c

mkdir -p Sources/CLibical/Public
echo "#include <stdio.h>" > Sources/CLibical/Public/CLibical.h
echo "#include <stddef.h>" >> Sources/CLibical/Public/CLibical.h
echo "#include <time.h>" >> Sources/CLibical/Public/CLibical.h
for header in \
  libical/src/libical/libical_ical_export.h \
  libical/src/libical/icaltime.h \
  libical/src/libical/icalduration.h \
  libical/src/libical/icalperiod.h \
  libical/src/libical/icalenums.h \
  libical/src/libical/icaltypes.h \
  libical/src/libical/icalarray.h \
  libical/src/libical/icalrecur.h \
  libical/src/libical/icalattach.h \
  Sources/CLibical/include/icalderivedparameter.h \
  Sources/CLibical/include/icalderivedvalue.h \
  libical/src/libical/icalvalue.h \
  libical/src/libical/icalparameter.h \
  Sources/CLibical/include/icalderivedproperty.h \
  libical/src/libical/icalproperty.h \
  libical/src/libical/pvl.h \
  libical/src/libical/icalcomponent.h \
  libical/src/libical/icaltimezone.h \
  libical/src/libical/icaltz-util.h \
  libical/src/libical/icalparser.h \
  libical/src/libical/icalmemory.h \
  libical/src/libical/icalerror.h \
  libical/src/libical/icalrestriction.h \
  libical/src/libical/sspm.h \
  libical/src/libical/icalmime.h \
  libical/src/libical/icallangbind.h \
  libical/src/libical/icaltimezoneimpl.h
do
  cat "${header}" | sed 's/#include.*//g' >> Sources/CLibical/Public/CLibical.h
done
