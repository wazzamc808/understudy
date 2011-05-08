# Included by src/Makefile.am

bin_PROGRAMS+=NetflixPlayer

NetflixPlayer_SOURCES=                          \
Netflix/Player/UNDNetflixKeyboardDevice.m       \
Netflix/Player/UNDNetflixPlayer.m               \
Netflix/Player/main.m                           \
Utilities/UNDPasswordProvider.m                 \
Utilities/UNDPlayerWindow.m                     \
Utilities/UNDPluginControl.m                    \
Utilities/UNDPreferenceManager.m                \
Utilities/UNDVolumeControl.m

NetflixPlayer_LDADD = -lRemoteControlWrapper
