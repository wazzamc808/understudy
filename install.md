# Install #

## From DMG ##

The simplest way to install Understudy is with the [DMG installer](http://code.google.com/p/understudy/downloads/list). Download the DMG, open, read and accept the license, then drag the Understudy icon into the Front Row Plugins folder (you'll need to authenticate with a password).

## From Source ##

If you would like to install Understudy from source, it can be downloaded using the directions on the [repository checkout](http://code.google.com/p/understudy/source/checkout) page.
Note that development occurs on the repository trunk, so it might be wise to checkout the latest tagged release instead.

Once downloaded, the frappliance can be built by opening the xcodeproj in XCode or by executing `xcodebuild` from within the source directory. Copy the plugin `build/Release/frUnderstudy.frappliance` into `/System/Library/CoreServices/Front Row.app/Contents/PlugIns/`.


# Uninstall #

To uninstall Understudy, you will need administrator privileges. There are two approaches, both of which boil down to:

  1. Remove `frUnderstudy.frappliance` from `/System/Library/CoreServices/Front Row.app/Contents/PlugIns/`
  1. Restart Front Row (logging out should suffice).

## Terminal ##

At the command line, enter:<br>
<code>sudo rm -rf /System/Library/CoreServices/Front\ Row.app/Contents/PlugIns/frUnderstudy.frappliance</code>
<br>to remove the plugin and<br>
<code>killall Front\ Row</code><br>
to stop any Front Row process you have running.<br>
<br>
<h2>Finder</h2>

Open the hard drive in a finder window, then open:<br>
System<br>
Library<br>
Core Services<br>
Here you should be able to find Front Row. While holding down the control key, click on Front Row and select "Show Package Contents", then open:<br>
Contents<br>
Plugins<br>
Delete the folder named frUnderstudy,frappilance<br>
<br>
If you have the DMG download handy, it's provides an alias to the Front Row Plugins folder.<br>
<br>
To kill Front Row, open Activity Monitor (located in Applications->Utilities). Select the Front Row process (easier done if you select the "Process Name" heading to sort by name) and click the "Quit Process" button.