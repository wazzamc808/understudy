# Development #

Additional development support for Understudy is very welcome. If you have any problems downloading or building the plugin, please contact one of the developers or send a message to the [discussion list](http://groups.google.com/group/understudy-discuss).

The rest of this page will give an over-view of what is involved with extending Understudy. As a general node, in this discussion Front Row will commonly be referred to as simply FR. The internal name for the framework behind FR is know as Back Row, and abbreviated BR. Understudy is focused on providing access to freely available on-line video. While having access to other types of feeds (e.g., twitter or Facebook) in FR would be nice, it's not really in the scope of Understudy. Never the less, if you're thinking about starting something similar, feel free to ask questions on how to get started.

## Adding a new site ##

In order to add support for videos from a new site, there are several steps that must be implemented. These are largely focused around build a list of videos, and displaying a given video.

### Identify a series of videos ###

This is most often done by parsing an RSS feed. Using the [PubSub framework](http://developer.apple.com/library/mac/#documentation/InternetWeb/Conceptual/PubSub/Introduction/Introduction.html) is recommended, since it will allow feeds to be updated when the application is not running (reducing menu loading times). For each video there are several attributes that should be determined: title, url, thumbnail image, etc. Of these, the title and url are vital.

### Construct menu assets ###

Within the Front Row menu system, each video is represented by an [asset](http://code.google.com/p/understudy/source/browse/BRHeaders/BRMediaAsset-Protocol.h). Understudy has [sub-classed](http://code.google.com/p/understudy/source/browse/Base/BaseUnderstudyAsset.h) the Front Row asset, and using this class eases the process of creating the necessary menu elements.

### Collect menu assets ###

Each FR menu represents a collection of assets. In Understudy, each feed is handled by a [FeedMenuController](http://code.google.com/p/understudy/source/browse/Base/FeedMenuController.h). Each new video source should provide a FeedDelegate for this controller to provide the collection of assets.

### Allow main menu access ###

Modify [MainMenuController](http://code.google.com/p/understudy/source/browse/Menuing/MainMenuController.m) to recognize URLs for the new site, and correctly create a FeedMenuController for it (in the !assetForRow: method).

### Add Feed UI ###

Understudy will only allow the user to add feeds it expects to be able to handle. Modify the [AddFeedDialog](http://code.google.com/p/understudy/source/browse/Menuing/AddFeedDialog.m) to recognize feeds for the new site. Most video sites provide a menu for adding common feeds for a site, perhaps automatically detecting the user's account and their primary queue. This isn't necessary, but is a nice addition.

### Provide a controller ###

In order to display the video, the media asset should provide a controller for the video. Before creating an actual video player (below) simply display the web-page containing the video. The existing [YouTube](http://code.google.com/p/understudy/source/browse/YouTube/YouTubeController.m) controller does this along with some simple video control. If you have inherited from Understudy's [BaseController](http://code.google.com/p/understudy/source/browse/Base/BaseController.h), the implementation will handle hiding Front Row and returning to it (again, see the YouTube implementation's !controlWillDeactivate).

### Provide a player ###

Although the FR interface allows easy access to the menu system, it interferes with user input. Many on-line video players accept keyboard controls, but FR will not allow this. It is possible to inject mouse events, but this is cumbersome compared to keyboard events. The best solution is to build an entirely separate video player application. When the user selects a video from your feed (via the FR menu), launch the new player with the appropriate URL.

## General Notes ##

When developing for Understudy please:
  * Try to follow the [Google Objective-C style guide](http://google-styleguide.googlecode.com/svn/trunk/objcguide.xml).
  * Maintain the style of existing files when modifying them. Be especially mindful of whether tabs or spaces are used for indentation.
  * Provide feedback to the developers on this guide.