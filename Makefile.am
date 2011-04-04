ACLOCAL_AMFLAGS	= -I config

SUBDIRS=src


CONTENTS=Understudy.frappliance/Contents
INST_BINARY=config/install-sh
INST_RESOURCE=config/install-sh -m 644

all-local: bundle

.PHONY: bundle

bundle:                                                     \
${CONTENTS}/Info.plist                                      \
${CONTENTS}/MacOS/Understudy                                \
${CONTENTS}/Resources/ApplianceIcon.png                     \
${CONTENTS}/Resources/English.lproj/InfoPlist.strings       \
${CONTENTS}/SharedSupport/NetflixPlayer                     \
${CONTENTS}/SharedSupport/UNDExternalLauncher

${CONTENTS}/Info.plist: Info.plist
	${INST_RESOURCE} Info.plist $@

${CONTENTS}/MacOS/Understudy: src/Understudy
	${INST_BINARY} src/Understudy $@

${CONTENTS}/SharedSupport/NetflixPlayer: src/NetflixPlayer
	${INST_BINARY} src/NetflixPlayer $@

${CONTENTS}/SharedSupport/UNDExternalLauncher: src/UNDExternalLauncher
	${INST_BINARY} src/UNDExternalLauncher $@

${CONTENTS}/Resources/English.lproj/InfoPlist.strings: \
Resources/English.lproj/InfoPlist.strings
	${INST_RESOURCE} Resources/English.lproj/InfoPlist.strings $@

${CONTENTS}/Resources/ApplianceIcon.png: Resources/ApplianceIcon.png
	${INST_BINARY} Resources/ApplianceIcon.png $@

clean-local:
	rm -rf ${BUNDLE}
