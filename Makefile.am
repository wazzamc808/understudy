ACLOCAL_AMFLAGS	= -I config
AUTOMAKE_OPTIONS = subdir-objects

INST_BINARY=config/install-sh
INST_RESOURCE=config/install-sh -m 644

CONTENTS=Understudy.frappliance/Contents

PLAYERS= NetflixPlayer UNDExternalLauncher

bin_PROGRAMS= NetflixPlayer UNDExternalLauncher Understudy

CPPFLAGS = -IBBCiPlayer -IBase -IBRHeaders -INetflix -IMenuing  \
-IRemoteControlWrapper -IUtilities -IYouTube

OBJCFLAGS = -arch i386 -Wall -Wextra -fmessage-length=0 -pipe -std=c99  \
-isysroot /Developer/SDKs/MacOSX10.5.sdk -mmacosx-version-min=10.5      \
-gdwarf-2

LDFLAGS = -F/Users/kelsey/Documents/understudy/build/Debug                      \
-F/System/Library/PrivateFrameworks                                             \
-F/Developer/SDKs/MacOSX10.5.sdk/System/Library/PrivateFrameworks -framework    \
AppKit -framework ApplicationServices -framework BackRow -framework Carbon      \
-framework CoreAudio -framework Foundation -framework IOKit -framework PubSub   \
-framework Security -framework WebKit -framework Cocoa -framework QuartzCore    \
-framework ExceptionHandling -lxml2 

RemoteControlWrapper_SOURCES=                   \
RemoteControlWrapper/AppleRemote.m              \
RemoteControlWrapper/FrontRowKeyboardDevice.m   \
RemoteControlWrapper/GlobalKeyboardDevice.m     \
RemoteControlWrapper/HIDRemoteControlDevice.m   \
RemoteControlWrapper/MultiClickRemoteBehavior.m \
RemoteControlWrapper/RemoteControl.m            \
RemoteControlWrapper/RemoteControlContainer.m

UND_UTILITY_SOURCES=                            \
Menuing/UNDPreferenceManager.m                  \
Utilities/UNDFileAsset.m                        \
Utilities/UNDFileBrowser.m                      \
Utilities/UNDFileCollection.m                   \
Utilities/UNDIconProvider.m                     \
Utilities/UNDPasswordProvider.m                 \
Utilities/UNDPlayerWindow.m                     \
Utilities/UNDPluginControl.m                    \
Utilities/UNDVolumeControl.m 

NetflixPlayer_SOURCES=                          \
${RemoteControlWrapper_SOURCES}                 \
Menuing/UNDPreferenceManager.m                  \
Netflix/Player/UNDNetflixKeyboardDevice.m       \
Netflix/Player/UNDNetflixPlayer.m               \
Netflix/Player/main.m                           \
Utilities/UNDPasswordProvider.m                 \
Utilities/UNDPlayerWindow.m                     \
Utilities/UNDPluginControl.m                    \
Utilities/UNDVolumeControl.m

UNDExternalLauncher_SOURCES= Base/UNDExternalLauncher.m

BBCiPlayer_SOURCES = BBCiPlayer/UNDNSXMLElement+Parsing.m               \
BBCiPlayer/UNDiPlayerAddDialog.m BBCiPlayer/UNDiPlayerAsset.m           \
BBCiPlayer/UNDiPlayerAssetProvider.m BBCiPlayer/UNDiPlayerController.m  \
BBCiPlayer/UNDiPlayerFeed.m

Netflix_SOURCES = Netflix/UNDNetflixAddDialog.m Netflix/UNDNetflixAsset.m   \
Netflix/UNDNetflixAssetProvider.m Netflix/UNDNetflixCollection.m            \
Netflix/UNDNetflixController.m Netflix/UNDNetflixFeed.m                     \
Netflix/UNDNetflixLoadingController.m

YouTube_SOURCES = YouTube/UNDYouTubeAddDialog.m YouTube/UNDYouTubeAsset.m   \
YouTube/UNDYouTubeAssetProvider.m YouTube/UNDYouTubeController.m            \
YouTube/UNDYouTubeFeed.m

Understudy_SOURCES =                            \
UNDAppliance.m                                  \
Base/UNDAssetFactory.m                          \
Base/UNDBaseAsset.m                             \
Base/UNDBaseCollection.m                        \
Base/UNDBaseController.m                        \
Base/UNDCollectionAddDialog.m                   \
Base/UNDCollectionProvider.m                    \
Base/UNDExternalAppAddDialog.m                  \
Base/UNDExternalAppAsset.m                      \
Base/UNDExternalAppAssetProvider.m              \
Base/UNDExternalLaunchController.m              \
Base/UNDExternalLauncher.m                      \
Base/UNDLoadingAsset.m                          \
Base/UNDMenuController.m                        \
Base/UNDMutableCollection.m                     \
Base/UNDUnknownAsset.m                          \
Menuing/UNDAddAssetDialog.m                     \
Menuing/UNDEditDialog.m                         \
Menuing/UNDManageDialog.m                       \
${BBCiPlayer_SOURCES}                           \
${Netflix_SOURCES}                              \
${RemoteControlWrapper_SOURCES}                 \
${UND_UTILITY_SOURCES}                          \
${YouTube_SOURCES}

Understudy_LDFLAGS = -bundle

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

${CONTENTS}/MacOS/Understudy: Understudy
	${INST_BINARY} Understudy $@

${CONTENTS}/SharedSupport/NetflixPlayer: NetflixPlayer
	${INST_BINARY} NetflixPlayer $@

${CONTENTS}/SharedSupport/UNDExternalLauncher: UNDExternalLauncher
	${INST_BINARY} UNDExternalLauncher $@

${CONTENTS}/Resources/English.lproj/InfoPlist.strings: \
Resources/English.lproj/InfoPlist.strings
	${INST_RESOURCE} Resources/English.lproj/InfoPlist.strings $@

${CONTENTS}/Resources/ApplianceIcon.png: Resources/ApplianceIcon.png
	${INST_BINARY} Resources/ApplianceIcon.png $@

clean-local:
	rm -rf ${BUNDLE}
