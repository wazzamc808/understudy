# Usage #

## Adding Feeds ##

There are a few ways to add feeds to Understudy:
  1. Using provided feeds (like Hulu's popular shows)
  1. Letting Understudy automatically discover your profile
  1. Copying a feed from the clipboard
Each of theses options is available for each video provider.

Start Front Row and select Understudy, Manage Feeds, Add, and then the provider you're interested in. You will be presented with a default set of feeds, and any that you select will appear in the main Understudy menu.

If you are logged into your account through Safari, you should also see a few options (depending on the website) that are specific to you. There may be a slight delay between the menu loading and your profile's feeds being added.

If you know the URL for a feed that you would like to add, you can copy it to the clipboard (outside of Front Row) and it will be available as the "URL in Clipboard" option. Please be sure that the URL you have copied is for a feed, and not for a page like http://www.hulu.com

Details for YouTube feeds are at http://www.youtube.com/rssls



## Watching Video ##

From the main Understudy menu you should be able to select a feed you have added. Once the feed loads, you can select a video (or sub-feed depending on what it contains) to watch.

### Hulu ###

#### Hulu Desktop ####

The recommended method for viewing Hulu video is through their official "Hulu Desktop" player. Once it is installed in `/Applications` Understudy will add a menu item to launch it.

http://www.hulu.com/labs/hulu-desktop

To get fullscreen working, start the Hulu Desktop explicitly and press Command-F. If you exit from the player while it is in fullscreen mode (go into the menu and select "Exit") it will start in fullscreen the next time. The official player will always start on the primary display.


#### Internal Player ####

If the video is rated mature (e.g. PG-13/TV-MA or higher) you will need to be logged in to the Hulu site (see below). Being logged in will also allow you to indicate that higher resolution video should be used by default in your Hulu profile preferences.

The left/right control buttons will allow you to select some of the flash player buttons (change the display resolution, fullscreen the player). Pressing play/pause while the indicator is over a button will activate it. Otherwise it will play/pause the video.

Once video is in fullscreen mode, left/right will move the mouse selector along the video time-line. Pressing play will select the position. After a brief pause, the selector will disappear and restore play/pause functionality.

### Netflix ###

The requirement for watching Netflix video are essentially the same as for watching it in a web browser. The only addition is that you will need to be logged in to the Netflix site (see below). The video will be not full-screen per se, but it should nearly fill your screen.


## Logging In ##

You must login to sites through Safari prior to opening Understudy (sorry, it must be Safari). Once you are logged in, Understudy can share Safari's credentials to access the video. You do not need to keep the page open, or be viewing any particular page in Safari for Understudy to work. Don't be surprised if a site automatically logs you out after some time (several days).

## Hidden Options ##

### Deactivating Alerts ###

When Understudy fails to load a video (particularly Netflix) it will attempt to display a user friendly alert. If you're sure everything is setup properly and it still isn't working, you can have Understudy show the video's web-page in order to see what's going wrong.

Open Terminal.app and enter the following to activate this feature:<br>
<code>defaults write com.apple.frontrow.appliance.understudy disableAlerts -bool YES</code>

To return to the old behavior, enter:<br>
<code>defaults delete com.apple.frontrow.appliance.understudy disableAlerts</code>


<h3>Site Login (Beta)</h3>

For sites that require user login in order to access (some) video, you can indicate to Understudy what your username for that site is. This requires that you have the password information stored in the OS X keychain. The first time that Understudy attempts to access the keychain item, it will briefly drop out of Front Row to allow you to authorize and authenticate the keychain access.<br>
<br>
<ol><li>Open <code>/Applications/Utilities/Keychain Access.app</code>
</li><li>Search for hulu (or netflix) and make note of the username. If there isn't an entry for the site, you'll need to login through a browser and have it record the password.<br>
</li><li>Open Terminal.app<br>
</li><li>Copy the following to the command line:<br> <code>defaults write com.apple.frontrow.appliance.understudy accounts -dict-add "www.hulu.com" "username"</code> <br> Replace the username with your account name (and for Netflix, replace hulu with netflix).<br>
</li><li>Press enter</li></ol>
