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

#import <BackRow/BRAlertController.h>
#import <BackRow/BRControllerStack.h>
#import <BackRow/BRDisplayManager.h>
#import <BackRow/BREvent.h>
#import <BackRow/BRRenderScene.h>
#import <BackRow/BRSentinel.h>
#import <BackRow/BRSettingsFacade.h>

#import <Carbon/Carbon.h>

#define AGENTSTRING @"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_5_6; en-us)"\
" AppleWebKit/525.27.1 (KHTML, like Gecko) Version/3.2.1 Safari/525.27.1"

@interface BRAppManager : NSObject { }
+ (BRAppManager*)sharedApplication;
- (id)delegate;
@end

@protocol  BRAppManagerDelegate
- (void)_continueDestroyScene:id;
@end

@interface BRRenderer{}
- (void)orderIn;
- (void)orderOut;
@end

@interface NetflixController (private)
- (void)_loadVideo;
- (void)_reveal;
- (void)_returnToFR;
- (void)_sendKeyCode:(int)keyCode withCharCode:(int)charCode;
- (WebView*)_pluginView;
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
  NSRect rect = [[NSScreen mainScreen] frame];
  view_ = [[[WebView alloc] initWithFrame:rect] retain];
  [[[view_ mainFrame] frameView] setAllowsScrolling:NO];
  [view_ setFrameLoadDelegate:self];
  window_ = [[[NSWindow alloc] initWithContentRect:rect 
                                         styleMask:0 
                                           backing:NSBackingStoreBuffered 
                                             defer:YES] retain];
  [window_ setContentView:view_];
  NSURLRequest* pageRequest = [NSURLRequest requestWithURL:[asset_ url]];
  NSLog(@"user agent: %@",[view_ customUserAgent]);
  [view_ setCustomUserAgent:AGENTSTRING];
  [[view_ mainFrame] loadRequest:pageRequest];
}

// <WebFrameLoadDelegate> callback once the video loads
- (void)webView:(WebView*)view didFinishLoadForFrame:(WebFrame*)frame
{
  if( frame != [view mainFrame] ) return;
  [window_ display];
  BRDisplayManager* manager = [BRDisplayManager sharedInstance];
  NSDictionary* mode = [manager displayMode];
  NSArray* objects = [NSArray arrayWithObjects: NSFullScreenModeAllScreens,
                      NSFullScreenModeWindowLevel,
                      NSFullScreenModeSetting,
                      nil ];
  NSArray* keys = [NSArray arrayWithObjects: [NSNumber numberWithBool:YES],
                   [NSNumber numberWithInt:14],
                   mode,
                   nil ];
  NSDictionary* options = [NSDictionary dictionaryWithObjects:objects
                                                      forKeys:keys];
  // if there is a plugin, we want to fullscreen it. if not (e.g. if the user
  // isn't logged in and the movie won't be shown) we report an error
  if( [self _pluginView] )
  {
    [pluginView_ enterFullScreenMode:[NSScreen mainScreen]
                         withOptions:options];  
    [self _reveal];
  } else {
    NSString* title = @"Error";
    NSString* primary = @"Video Could Not Be Loaded";
    NSString* secondary = @"Please ensure that you are logged into your Netfli"\
    "x account in Safari, and that you have not reached your viewing limit";
    BRAlertController* alert = [BRAlertController alertOfType:kBRAlertTypeError
                                                       titled:title
                                                  primaryText:primary
                                                secondaryText:secondary];
    [[self stack] swapController:alert];
  }
}

// order out the FR window, revealing the video display
- (void)_reveal
{
  BRSentinel* sentinel = [BRSentinel sharedInstance];
  id<BRRendererProvider> provider = [sentinel rendererProvider];
  BRRenderer* renderer = [provider renderer];
  [renderer orderOut];
}

// bring back the FR display, unshield the menu, close the player
- (void) _returnToFR
{
  BRSentinel* sentinel = [BRSentinel sharedInstance];
  id<BRRendererProvider> provider = [sentinel rendererProvider];
  BRRenderer* renderer = [provider renderer];
  [pluginView_ exitFullScreenModeWithOptions:nil];
  [renderer orderIn];  
  [window_ close];
  [view_ close];
  window_ = nil;
  view_ = nil;
}

// grab the web view for the flash player
- (WebView*)_pluginView
{
  NSMutableSet* views = [[[NSMutableSet set] retain] autorelease];
  NSMutableSet* webviews = [[[NSMutableSet set] retain] autorelease];
  [views addObjectsFromArray:[view_ subviews]];
  while( [views count] ){
    WebView* view = [views anyObject];
    if( [[view className] isEqual:@"WebNetscapePluginDocumentView"] )
      [webviews addObject:view];
    [views addObjectsFromArray:[view subviews]];
    [views removeObject:view];
  }
  if( [webviews count] < 1 ) NSLog(@"got no plugin views");
  else
  {
    if( [webviews count] > 1 ) NSLog(@"got multiple plugin views");
    pluginView_ = [webviews anyObject];
    [pluginView_ retain];
  }
  return pluginView_;
}

// Send a keydown (and up) event to the web view holding the flash plugin
// (using NSEvent doesn't work)
- (void)_sendKeyCode:(int)keyCode withCharCode:(int)charCode;
{
  WebView* view = [self _pluginView];
  EventRecord event; 
  event.what = keyDown; 
  event.message = (keyCode << 8) + charCode;
  event.modifiers = 0;
  [(id)view sendEvent:(NSEvent *)&event];
  event.what = keyUp;
  [(id)view sendEvent:(NSEvent *)&event];
  [view autorelease];
}

- (void)playPause
{
  [self _sendKeyCode:49 withCharCode:0]; // space-bar
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
  [self _returnToFR];
}

- (BOOL)isNetworkDependent
{
  return YES;
}

// play/pause works as expected, anythings else will fullscren the flash player
- (BOOL)brEventAction:(BREvent*)event
{
  BRSettingsFacade* settings;
  switch ([event remoteAction]) {
    case kBRRemotePlayPauseSelectButton:
      [self playPause];
      return YES;
      break;
    case kBRRemoteUpButton:
      settings = [BRSettingsFacade sharedInstance];
      [settings setSystemVolume:([settings systemVolume]+0.1)];
      return YES;
    case kBRRemoteDownButton:
      settings = [BRSettingsFacade sharedInstance];
      [settings setSystemVolume:([settings systemVolume]-0.1)];
      return YES;
    default:
      return [super brEventAction:event];
  }
}

@end
