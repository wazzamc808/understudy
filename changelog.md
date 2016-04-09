# Changelog #

## 0.8 (Jan 2010) ##

### 0.8.2 ###

Known Issue: there is a known crash occurring when Netflix queues update episodic information ([issue #144](https://code.google.com/p/understudy/issues/detail?id=#144)).

  * Adjusted Netflix episode handling to account for changes in the Netflix website ([issue #147](https://code.google.com/p/understudy/issues/detail?id=#147)) - thanks to Pete Harllee for the patch
  * Updated the URLs used for Hulu queue and subscription feeds ([issue #101](https://code.google.com/p/understudy/issues/detail?id=#101))

### 0.8.1 ###

  * Fixed volume controls for the Netflix player ([issue #135](https://code.google.com/p/understudy/issues/detail?id=#135))
  * Improved handling of Netflix series as a collection of episodes ([issue #127](https://code.google.com/p/understudy/issues/detail?id=#127))
  * Fixed an error preventing players from working on Mac OX 10.5 ([issue #138](https://code.google.com/p/understudy/issues/detail?id=#138))

### 0.8.0 ###

  * Standalone Netflix Player
  * Fixed play/pause support for Safari 3 ([issue #100](https://code.google.com/p/understudy/issues/detail?id=#100))
  * Netflix full-screen support added ([issue #2](https://code.google.com/p/understudy/issues/detail?id=#2))

## 0.7 (May 2009) ##

  * Hulu Desktop support
  * Improved handling of Netflix episodes ([issue #99](https://code.google.com/p/understudy/issues/detail?id=#99))
  * Introduced a Hulu player with limited FF/REW support
  * Improved Hulu fullscreen handling ([issue #46](https://code.google.com/p/understudy/issues/detail?id=#46))

## 0.6 (March 2009) ##

  * YouTube support

### 0.6.9 ###

  * Convert some YouTube feed URLs automatically ([issue #94](https://code.google.com/p/understudy/issues/detail?id=#94) & [issue #95](https://code.google.com/p/understudy/issues/detail?id=#95))
  * Tweaked the season grouping of Netflix TV episodes.

### 0.6.8 ###

  * Netflix television seasons become a sub-menu with individual episodes listed instead of loading the first episode of the season ([issue #10](https://code.google.com/p/understudy/issues/detail?id=#10)) - thanks to Greg Murray for an initial implementation patch.

### 0.6.7 ###

  * Fixes to the keychain access ([issue #91](https://code.google.com/p/understudy/issues/detail?id=#91))
  * Support for iPlayer menus

### 0.6.6 ###

  * Automatic login for Hulu and Netflix (see usage wiki page - [issue #6](https://code.google.com/p/understudy/issues/detail?id=#6)).
  * Accept feed:// urls ([issue #84](https://code.google.com/p/understudy/issues/detail?id=#84))
  * Place the selector boxes properly on secondary displays ([issue #87](https://code.google.com/p/understudy/issues/detail?id=#87))

### 0.6.5 ###

  * Prevent display sleep while playing ([issue #25](https://code.google.com/p/understudy/issues/detail?id=#25))
  * Shield non-main displays ([issue #80](https://code.google.com/p/understudy/issues/detail?id=#80))

### 0.6.4 ###

  * Detect missing Silverlight plugin ([issue #79](https://code.google.com/p/understudy/issues/detail?id=#79))
  * Introduce a user driven button selector. This allows user selection of the fullscreen button ([issue #46](https://code.google.com/p/understudy/issues/detail?id=#46)), as well as the Hi/Standard resolution ([issue #16](https://code.google.com/p/understudy/issues/detail?id=#16))

### 0.6.3 ###

  * Introduce an option to disable Understudy alerts (and see the raw webpage instead)
  * Ensure that preferences load properly for first time users (issue
  * fixed a regression that allowed the menu and dock to show with Netflix ([issue #70](https://code.google.com/p/understudy/issues/detail?id=#70))

## 0.5 (Feb 2009) ##

  * Display improvements

### 0.5.4 ###

  * restored play/pause functionality to Hulu video
  * respect setting for FR display ([issue #26](https://code.google.com/p/understudy/issues/detail?id=#26))
  * move preferences out of com.apple namespace ([issue #28](https://code.google.com/p/understudy/issues/detail?id=#28))
  * feedback while feeds and videos are loading ([issue #52](https://code.google.com/p/understudy/issues/detail?id=#52))
  * prevent a crash while making Hulu videos fullscreen ([issue #62](https://code.google.com/p/understudy/issues/detail?id=#62))

### 0.5.3 ###

  * Switch to using a mouseclick to activate fullscreen (the keyboard shortcut was removed)

### 0.5.2 ###

  * Properly fullscreen Hulu video

### 0.5.1 ###
  * Changed the Hulu display so that videos aren't reported as unavailable ([issue 51](https://code.google.com/p/understudy/issues/detail?id=51)). Video pages load as they would in a browser, and are only made full-screen when the user presses right (button on the remote, or arrow on the keyboard)
  * Added an preference for order within FR ([issue 7](https://code.google.com/p/understudy/issues/detail?id=7))
  * Fixed a crash on reordering feeds ([issue 35](https://code.google.com/p/understudy/issues/detail?id=35))
  * Fixed a crash when adding a feed from the clipboard ([issue 42](https://code.google.com/p/understudy/issues/detail?id=42))
  * Hulu feeds in which all videos have the same title (like the feed for a show) now indicate episode information in the menu.

### 0.5.0 ###
  * Support for feeds of shows such as a users subscriptions (Hulu)
  * Support for user defined aspect ratios by series (Hulu)
  * Properly maintained aspect ratio ([issue 14](https://code.google.com/p/understudy/issues/detail?id=14) - Netflix)

## 0.4 (Jan 2009) ##

  * Support for volume control
  * Properly centered video on wide screens ([issue 3](https://code.google.com/p/understudy/issues/detail?id=3) - Hulu)
  * Support for PPC ([issue 11](https://code.google.com/p/understudy/issues/detail?id=11))

## 0.3 (Dec 28 2008) ##

  * Support for Netflix Video
  * Fixed crash when remote buttons are pressed ([issue 5](https://code.google.com/p/understudy/issues/detail?id=5) - v0.3.2)

## 0.2 (Dec 15 2008) ##

  * Support for play/pause functionality

## 0.1 (Dec 6 2008) ##

  * Support for Hulu Video