AUTOMAKE_OPTIONS = subdir-objects

bin_PROGRAMS=UNDExternalLauncher Understudy

CPPFLAGS = -IBBCiPlayer -IBase -IBRHeaders -INetflix -IMenuing  \
-IRemoteControlWrapper -IUtilities -IYouTube

OBJCFLAGS =                                     \
-arch i386                                      \
-Wall                                           \
-Wextra                                         \
-fmessage-length=0                              \
-pipe                                           \
-std=c99                                        \
-isysroot /Developer/SDKs/MacOSX10.5.sdk        \
-mmacosx-version-min=10.5                       \
-gdwarf-2

LDFLAGS =                                                           \
-F/System/Library/PrivateFrameworks                                 \
-F/Developer/SDKs/MacOSX10.5.sdk/System/Library/PrivateFrameworks   \
-framework AppKit                                                   \
-framework ApplicationServices                                      \
-framework BackRow                                                  \
-framework Carbon                                                   \
-framework CoreAudio                                                \
-framework Foundation                                               \
-framework IOKit                                                    \
-framework PubSub                                                   \
-framework Security                                                 \
-framework WebKit                                                   \
-framework Cocoa                                                    \
-framework QuartzCore                                               \
-framework ExceptionHandling                                        \
-lxml2                                                              \
-L.

include RemoteControlWrapper/local.mk
include Netflix/Player/local.mk

UNDExternalLauncher_SOURCES= Base/UNDExternalLauncher.m

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
Menuing/UNDPreferenceManager.m                  \
BBCiPlayer/UNDNSXMLElement+Parsing.m            \
BBCiPlayer/UNDiPlayerAddDialog.m                \
BBCiPlayer/UNDiPlayerAsset.m                    \
BBCiPlayer/UNDiPlayerAssetProvider.m            \
BBCiPlayer/UNDiPlayerController.m               \
BBCiPlayer/UNDiPlayerFeed.m                     \
Netflix/UNDNetflixAddDialog.m                   \
Netflix/UNDNetflixAsset.m                       \
Netflix/UNDNetflixAssetProvider.m               \
Netflix/UNDNetflixCollection.m                  \
Netflix/UNDNetflixController.m                  \
Netflix/UNDNetflixFeed.m                        \
Netflix/UNDNetflixLoadingController.m           \
Utilities/UNDFileAsset.m                        \
Utilities/UNDFileBrowser.m                      \
Utilities/UNDFileCollection.m                   \
Utilities/UNDIconProvider.m                     \
Utilities/UNDPasswordProvider.m                 \
Utilities/UNDPlayerWindow.m                     \
Utilities/UNDPluginControl.m                    \
Utilities/UNDVolumeControl.m                    \
YouTube/UNDYouTubeAddDialog.m                   \
YouTube/UNDYouTubeAsset.m                       \
YouTube/UNDYouTubeAssetProvider.m               \
YouTube/UNDYouTubeController.m                  \
YouTube/UNDYouTubeFeed.m


Understudy_LDFLAGS = -bundle
Understudy_LDADD   = -lRemoteControlWrapper
