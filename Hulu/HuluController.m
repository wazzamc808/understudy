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

#import <BackRow/BRControllerStack.h>
#import <BackRow/BRDisplayManager.h>
#import <BackRow/BREvent.h>
#import <BackRow/BRRenderScene.h>
#import <BackRow/BRSentinel.h>
#import <BackRow/BRSettingsFacade.h>
#import <BackRow/BRAlertController.h>
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
  
  // send an F keystroke to the player
  [self sendPluginKeyCode:3  withCharCode:102];
  
  // check the set of windows belonging to the application. we created one
  // explicitly. anything else is the flash player creating it's own
  NSArray* windows = [[NSApplication sharedApplication] windows];
  [[windows retain] autorelease];
  if( [windows count] < 3 ){
    NSLog(@"flash didn't fullscreen");
    return NO;
  }
  
  // loop over all of the windows (with luck there will just be two)
  for ( NSWindow* window in windows )
  {
    // when we find something other than the original window, force disply
    // (the flash fullscreen window tends to initially be blank)
    if( window != window_ && window != menushield_ )
    {
      fsWindow_ = [window retain];
      [fsWindow_ display];
    }
  }  

  NSPoint fsPoint = {752,31};
  [self sendPluginMouseClickAtPoint:fsPoint];
  
  return YES;
}

- (void)exitFullScreen
{
  [self sendPluginKeyCode:53 withCharCode:27];
}

// <WebFrameLoadDelegate> callback once the video loads
- (void)webView:(WebView*)view didFinishLoadForFrame:(WebFrame*)frame
{
  if( frame != [view mainFrame] ) return;

  [window_ display];
  [window_ orderFrontRegardless];
  
  [self shieldMenu];
  [self reveal];
}

- (void)playPause
{
  [self sendPluginKeyCode:49 withCharCode:0]; // space-bar
}

// currently kludging FF to be a fullscreen
- (void)fastForward
{
  [self fullscreenFlash];
}

#pragma mark BR Control

- (void)controlWillActivate
{
  [super controlWillActivate];
  alert_ = nil;
  [self _loadVideo];
}

- (void)controlWillDeactivate
{
  // enlarge the shield to hide the transition
  [menushield_ setFrame:[[UNDPreferenceManager screen] frame] display:NO];
  
  if( fsWindow_ ){
    [self exitFullScreen];
    [fsWindow_ close];
    fsWindow_ = nil;
  }
  [window_ close];
  window_ = nil;
  [self returnToFR];
  
  [menushield_ close];
  [super controlWillDeactivate];
}

@end
