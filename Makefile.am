ACLOCAL_AMFLAGS	= -I config

SUBDIRS=src
include doc/doxygen.am

CONTENTS=Understudy.frappliance/Contents
INSTALL=config/install-sh

BUNDLE_FILES=                                   \
${CONTENTS}/MacOS/Understudy                    \
${CONTENTS}/SharedSupport/NetflixPlayer         \
${CONTENTS}/SharedSupport/UNDExternalLauncher

CLEANFILES=${BUNDLE_FILES}

all-local: ${BUNDLE_FILES}

${CONTENTS}/MacOS/Understudy: src/Understudy
	${INSTALL} src/Understudy $@

${CONTENTS}/SharedSupport/NetflixPlayer: src/NetflixPlayer
	${INSTALL} src/NetflixPlayer $@

${CONTENTS}/SharedSupport/UNDExternalLauncher: src/UNDExternalLauncher
	${INSTALL} src/UNDExternalLauncher $@

