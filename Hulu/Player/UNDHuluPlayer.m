//
//  Copyright 2008-2009 Kirk Kelsey.
//
//  This file is part of Understudy.
//
//  Understudy is free software: you can redistribute it and/or modify it under
//  the terms of the GNU Lesser General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option)
//  any later version.
//
//  Understudy is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
//  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License
//  for more details.
//
//  You should have received a copy of the GNU Lesser General Public License
//  along with Understudy.  If not, see <http://www.gnu.org/licenses/>.

#include <regex.h>

#import "UNDHuluPlayer.h"
#import "UNDHuluSelector.h"
#import "UNDHuluFSSelector.h"
#import "UNDPasswordProvider.h"
#import "UNDPluginControl.h"
#import "UNDPreferenceManager.h"

#import "BRSettingsFacade.h"

#import <Carbon/Carbon.h>

@implementation UNDHuluPlayer

- (void)dealloc
{
  [pluginControl_ release];
  [selector_ release];
  [super dealloc];
}

- (void)loadURL:(NSURL*)url
{
  NSScreen* screen = [UNDPreferenceManager screen];
  NSRect rect = [screen frame];
  rect.origin.x = rect.origin.y = 0;
  mainView_ = [[WebView alloc] initWithFrame:rect];
  [[[mainView_ mainFrame] frameView] setAllowsScrolling:NO];
  [mainView_ setFrameLoadDelegate:self];
  window_ = [[NSWindow alloc] initWithContentRect:rect
                                        styleMask:NSTitledWindowMask
                                          backing:NSBackingStoreBuffered
                                            defer:YES
                                           screen:screen];
  [window_ display];
  [window_ orderFrontRegardless];
  [window_ setLevel:NSScreenSaverWindowLevel];
  [window_ setContentView:mainView_];
  NSURLRequest* pageRequest = [NSURLRequest requestWithURL:url];
  [[mainView_ mainFrame] loadRequest:pageRequest];
  pluginControl_ = [[UNDPluginControl alloc] initWithView:mainView_];
}

- (NSWindow*)findFullscreenWindow
{
  if( fsWindow_ ) return fsWindow_;

  // check the set of windows belonging to the application. we created one
  // explicitly so any other large window is the flash player creating it's own
  NSArray* windows = [[NSApplication sharedApplication] windows];
  int expectedWindows = 1;
  [[windows retain] autorelease];
    if( [windows count] <= expectedWindows ) return nil;

  for ( NSWindow* window in windows )
  {
    NSRect screen = [[UNDPreferenceManager screen] frame];
    NSRect windowFrame = [window frame];
    if( windowFrame.size.height == screen.size.height
        && windowFrame.size.width == screen.size.width
        && window != window_ )
    {
      fsWindow_ = [window retain];
      [window_ orderOut:self];
      [selector_ release];
      selector_ = [[UNDHuluFSSelector alloc] 
                    initWithScreen:[UNDPreferenceManager screen]];
    }
  }
  return fsWindow_;
}

// tell the flash player to go fullscreen. we only try once, so the caller
// should check for success (i.e. |fsWindow| != nil) if necessary
- (BOOL)fullscreenFlash
{
  [selector_ select];
  if( !fsWindow_ ) [self findFullscreenWindow];
  return (fsWindow_ != nil);
}

- (void)ensureLogin
{
  WebScriptObject* script = [mainView_ windowScriptObject];
  // check for the presence of a $("login") element
  id result = [script evaluateWebScript:@"document.getElementById('login')"];
  if( result == [WebUndefined undefined] ) return;

  // if it is there, try to login
  NSString* user = [UNDPreferenceManager accountForService:@"www.hulu.com"];
  [[user retain] autorelease];
  if( !user ) return;

  NSString* pass = [UNDPasswordProvider passwordForService:@"www.hulu.com"
                                                   account:user];
  if( !pass ){
    pass = [UNDPasswordProvider passwordForService:@"secure.hulu.com"
                                           account:user];
  }
  if( !pass ) return;
  [[pass retain] autorelease];

  NSString* setPass = @"document.getElementById('password').value='%@'";
  NSString* setUser = @"document.getElementById('login').value='%@'";
  NSString* submit = @"document.getElementById('login').parentNode.onsubmit()";

  setPass = [NSString stringWithFormat:setPass,pass];
  setUser = [NSString stringWithFormat:setUser,user];
  result = [script evaluateWebScript:setPass];
  result = [script evaluateWebScript:setUser];
  result = [script evaluateWebScript:submit];
}

// periodically check for a fullscreen window. since the user can click the 
// button explicitly it doesn't suffice to check when it's done programatically
- (void)lookForFullscreen
{
  if( ![self findFullscreenWindow] )
    [self performSelector:@selector(lookForFullscreen)
               withObject:nil
               afterDelay:1];
}

// activate the application
- (void)activate
{
  NSString* name = 
    [[[[NSProcessInfo processInfo] processName] retain] autorelease];
  NSString* source = 
    @"tell application \"System Events\" to activate application \"%@\"";
  source = [NSString stringWithFormat:source,name];
  NSAppleScript* script = [[NSAppleScript alloc] initWithSource:source];
  NSDictionary* err;
  [script executeAndReturnError:&err];
}

// <WebFrameLoadDelegate> callback once the video loads
- (void)webView:(WebView*)view didFinishLoadForFrame:(WebFrame*)frame
{
  if( frame != [view mainFrame] ) return;
  [self activate];
  [self ensureLogin];
  [self lookForFullscreen];
  selector_ = [[UNDHuluSelector alloc] initWithView:[pluginControl_ plugin]];
}

- (void)playPause
{
  if( [selector_ locationIsValid] ) [self fullscreenFlash];
  else [pluginControl_ sendPluginKeyCode:49 withCharCode:0]; // space-bar
}

- (void)fastForward
{
  [selector_ nextPosition];
}

- (void)rewind
{
  [selector_ prevPosition];
}

- (void)returnToFrontRow
{
  // launch Front Row using the launcher app (not the application itself)
  NSWorkspace* work = [NSWorkspace sharedWorkspace];
  [work launchAppWithBundleIdentifier:@"com.apple.frontrowlauncher"
                              options:NSWorkspaceLaunchDefault
       additionalEventParamDescriptor:[NSAppleEventDescriptor nullDescriptor]
                     launchIdentifier:nil];
  // wait around until FR has taken over, then die
  [self playPause];
  [pluginControl_ sendPluginKeyCode:53 withCharCode:27]; // press 'esc'
  [NSApp performSelector:@selector(terminate:) withObject:self afterDelay:5];
}

- (void)sendRemoteButtonEvent:(RemoteControlEventIdentifier)event 
                  pressedDown:(BOOL)pressedDown 
                remoteControl:(RemoteControl*)remoteControl 
{
  // ignore button release events
  if( !pressedDown ) return;
  BRSettingsFacade* settings;
  switch(event){
    case kRemoteButtonPlus:
      settings = [BRSettingsFacade sharedInstance];
      [settings setSystemVolume:([settings systemVolume]+0.05)];
      break;
    case kRemoteButtonMinus:
      settings = [BRSettingsFacade sharedInstance];
      [settings setSystemVolume:([settings systemVolume]-0.05)];
      break;
    case kRemoteButtonMenu:
      [self returnToFrontRow];
      break;
    case kRemoteButtonPlay:
      if( pressedDown ) [self playPause];
      break;
    case kRemoteButtonRight:
      [self fastForward];
      break;
    case kRemoteButtonLeft:
      [self rewind];
      break;
  }
}

@end
