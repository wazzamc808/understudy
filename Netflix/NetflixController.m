//
//  Copyright 2008 Kirk Kelsey.
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

#import "NetflixController.h"
#import "UNDPreferenceManager.h"

#import <BRAlertController.h>
#import <BRControllerStack.h>
#import <BRDisplayManager.h>
#import <BREvent.h>
#import <BRRenderScene.h>
#import <BRSentinel.h>
#import <BRSettingsFacade.h>

#import <Carbon/Carbon.h>

#define AGENTSTRING @"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_5_6; en-us)"\
" AppleWebKit/525.27.1 (KHTML, like Gecko) Version/3.2.1 Safari/525.27.1"

@protocol  BRAppManagerDelegate
- (void)_continueDestroyScene:id;
@end

@implementation NetflixController

- (id)initWithAsset:(NetflixAsset*)asset
{
  [super init];
  asset_ = [asset retain];
  return self;
}

- (void)dealloc
{
  [asset_ release];
  [super dealloc];
}

- (void)_loadVideo
{
  // invoking shared application ensures that windows can be ordered
  [NSApplication sharedApplication];
  NSRect rect = [[UNDPreferenceManager screen] frame];
  mainView_ = [[[WebView alloc] initWithFrame:rect] retain];
  [[[mainView_ mainFrame] frameView] setAllowsScrolling:NO];
  [mainView_ setFrameLoadDelegate:self];
  window_ = [[[NSWindow alloc] initWithContentRect:rect 
                                         styleMask:0 
                                           backing:NSBackingStoreBuffered 
                                             defer:YES] retain];
  [window_ setContentView:mainView_];
  NSURLRequest* pageRequest = [NSURLRequest requestWithURL:[asset_ url]];
  [mainView_ setCustomUserAgent:AGENTSTRING];
  [[mainView_ mainFrame] loadRequest:pageRequest];
}

// <WebFrameLoadDelegate> callback once the video loads
- (void)webView:(WebView*)view didFinishLoadForFrame:(WebFrame*)frame
{
  if( frame != [view mainFrame] ) return;
  [window_ display];
  // if there is a plugin, we want to fullscreen it. if not (e.g. if the user
  // isn't logged in and the movie won't be shown) we report an error
  if( [self hasPluginView] || [UNDPreferenceManager alertsAreDisabled]) {
    [window_ display];
    [window_ orderFrontRegardless];
    [window_ setLevel:NSScreenSaverWindowLevel];
    [self reveal];
  } else {
    NSString* title = @"Error";
    NSString* primary = @"Video Could Not Be Loaded";
    NSString* secondary = @"Please ensure that you are logged into your Netfli"\
    "x account in Safari, and that you have not reached your viewing limit.";
    BRAlertController* alert = [BRAlertController alertOfType:3
                                                       titled:title
                                                  primaryText:primary
                                                secondaryText:secondary];
    [[self stack] swapController:alert];
  }
}

- (void)fullscreen
{
  if( ![self hasPluginView] ){
    NSLog(@"cannot fullscreen netflix player (no plugin available)");
    return;
  }
  
  NSSize size = [pluginView_ frame].size;
  
  NSPoint fsPoint;
  // the fullscreen button is 30px high, and 30px up from the bottom edge
  fsPoint.y = -45;
  // the fullscreen button is 15px in from the right edge (and 70px wide)
  fsPoint.x = -(15 + 35);
  // if the player is more than 1000px wide, padding is added
  if( size.width > 1000 ) fsPoint.x -= (size.width-1000)/2;

  NSRect rect;
  rect.origin = fsPoint;
  rect.size.height = 10;
  rect.size.width = 10;
  NSWindow* window= [[NSWindow alloc] initWithContentRect:rect
                                                styleMask:0
                                                  backing:NSBackingStoreBuffered
                                                    defer:YES];
  [window setBackgroundColor:[NSColor greenColor]];
  [window display];
  [window setLevel:NSScreenSaverWindowLevel];
  [window orderFrontRegardless];
  
  [self sendPluginMouseClickAtPoint:fsPoint];
  [self sendPluginMouseClickAtPoint:fsPoint];
}

# pragma mark Player Controls

- (void)playPause
{
  [self sendPluginKeyCode:49 withCharCode:0]; // space-bar
}

- (void)fastForward
{
  [self fullscreen];
}

#pragma mark BR Control

- (void)controlWillActivate
{
  [super controlWillActivate];
  [self _loadVideo];
}

- (void)controlWillDeactivate
{
  [super controlWillDeactivate];
  [self returnToFR];
  [window_ close];
  window_ = nil;
}

@end
