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

#import "HuluController.h"
#import "MainMenuController.h"
#import "UNDPreferenceManager.h"
#import "UNDPasswordProvider.h"

#import <BRControllerStack.h>
#import <BRDisplayManager.h>
#import <BREvent.h>
#import <BRRenderScene.h>
#import <BRSentinel.h>
#import <BRSettingsFacade.h>
#import <BRAlertController.h>
#import <Carbon/Carbon.h>

@implementation HuluController

- (id)initWithAsset:(HuluAsset*)asset
{
  [super init];
  asset_ = [asset retain];
  return self;
}

- (void)dealloc
{
  [asset_ release];
  [selector_ release];
  [super dealloc];
}

- (void)_loadVideo
{
  // invoking shared application ensures that windows can be ordered
  [NSApplication sharedApplication];
  NSRect rect = [[UNDPreferenceManager screen] frame];
  mainView_ = [[WebView alloc] initWithFrame:rect];
  [[[mainView_ mainFrame] frameView] setAllowsScrolling:NO];
  [mainView_ setFrameLoadDelegate:self];
  window_ = [[NSWindow alloc] initWithContentRect:rect 
                                        styleMask:0
                                          backing:NSBackingStoreBuffered
                                            defer:YES];
  [window_ setContentView:mainView_];
  NSURLRequest* pageRequest = [NSURLRequest requestWithURL:[asset_ url]];
  [[mainView_ mainFrame] loadRequest:pageRequest];
}

// tell the flash player to go fullscreen. we only try once, so the caller 
// should check for success (i.e. |fsWindow| != nil) if necessary
- (BOOL)fullscreenFlash
{
  // abort if we already have a fullscreen window
  if( fsWindow_ ) return YES;
  
  // try clicking on the fullscreen button
  NSPoint fsPoint = [pluginView_ convertPointFromBase:[selector_ location]];
  
  [self sendPluginMouseClickAtPoint:fsPoint];
  [self sendPluginMouseClickAtPoint:fsPoint];
  
  // check the set of windows belonging to the application. we created one
  // explicitly. anything else is the flash player creating it's own
  NSArray* windows = [[NSApplication sharedApplication] windows];
  int expectedWindows = 1;
  if( selector_ ) expectedWindows++;
  [[windows retain] autorelease];
  if( [windows count] <= expectedWindows ) return NO;
  
  for ( NSWindow* window in windows )
  {
    if( window != window_ && window != [selector_ window])
    {
      fsWindow_ = [window retain];
      [fsWindow_ display];
      [fsWindow_ orderFrontRegardless];
      [fsWindow_ setLevel:NSScreenSaverWindowLevel];
      [window_ orderBack:self];
      [selector_ hide];
      [selector_ release];
      selector_ = nil;
    }
  }  

  return YES;
}

- (void)exitFullScreen
{
  [self sendPluginKeyCode:53 withCharCode:27];
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
  [[pass retain] autorelease];
  if( !pass ) return;
  
  NSString* setPass = @"document.getElementById('password').value='%@'";
  NSString* setUser = @"document.getElementById('login').value='%@'";
  NSString* submit = @"document.getElementById('login').parentNode.onsubmit()";

  setPass = [NSString stringWithFormat:setPass,pass];
  setUser = [NSString stringWithFormat:setUser,user];

  result = [script evaluateWebScript:setPass];
  result = [script evaluateWebScript:setUser];
  result = [script evaluateWebScript:submit];
}

// <WebFrameLoadDelegate> callback once the video loads
- (void)webView:(WebView*)view didFinishLoadForFrame:(WebFrame*)frame
{
  if( frame != [view mainFrame] ) return;

  [window_ display];
  [window_ orderFrontRegardless];
  [window_ setLevel:NSScreenSaverWindowLevel];
  [self ensureLogin];
  
  // the selector's origin is measured from the bottom up, while the view is 
  // down from the top. we get the plugin's location and flip it relative to
  // the main view, then take out the height of the plugin
  if( [self hasPluginView] ){

    NSPoint origin;
    origin = [pluginView_ frame].origin;
    origin.y = [mainView_ frame].size.height - origin.y;
    origin.y -= [pluginView_ frame].size.height;

    NSPoint screenOrigin = [[UNDPreferenceManager screen] frame].origin;
    origin.x += screenOrigin.x;
    origin.y += screenOrigin.y;    
    
    selector_ = [[UNDHuluSelector alloc] initWithOrigin:origin];
    [selector_ show];
  }
  
  [self reveal];
  
}

- (void)playPause
{
  if( [selector_ locationIsValid] )
    [self fullscreenFlash];
  else
    [self sendPluginKeyCode:49 withCharCode:0]; // space-bar
}

- (void)fastForward
{
  [selector_ nextPosition];
}

- (void)rewind
{
  [selector_ prevPosition];
}

#pragma mark BR Control

- (void)controlWillActivate
{
  [super controlWillActivate];
  [self _loadVideo];
}

- (void)controlWillDeactivate
{  
  if( fsWindow_ ){
    [self exitFullScreen];
    [fsWindow_ close];
    fsWindow_ = nil;
  }
  [selector_ release];
  selector_ = nil;
  [window_ close];
  window_ = nil;
  [self returnToFR];
  
  [super controlWillDeactivate];
}

@end
