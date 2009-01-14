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

#import "BaseController.h"

#import <BackRow/BRControllerStack.h>
#import <BackRow/BRDisplayManager.h>
#import <BackRow/BREvent.h>
#import <BackRow/BRRenderScene.h>
#import <BackRow/BRSentinel.h>
#import <BackRow/BRSettingsFacade.h>

#import <Carbon/Carbon.h>

@interface BRAppManager : NSObject { }
+ (BRAppManager*)sharedApplication;
- (id)delegate;
@end

@interface BRRenderer{}
- (void)orderIn;
- (void)orderOut;
@end

@implementation WebView (KeyboardShortcuts)
- (void)sendKeyCode:(int)keyCode withCharCode:(int)charCode
{
  EventRecord event; 
  event.what = keyDown; 
  event.message = (keyCode << 8) + charCode;
  event.modifiers = 0;
  [(id)self sendEvent:(NSEvent *)&event];
  event.what = keyUp;
  [(id)self sendEvent:(NSEvent *)&event];
}
@end

@implementation BaseController

- (void)reveal
{
  BRSentinel* sentinel = [BRSentinel sharedInstance];
  id<BRRendererProvider> provider = [sentinel rendererProvider];
  BRRenderer* renderer = [provider renderer];
  [renderer orderOut];  
}

- (void)returnToFR
{
  BRSentinel* sentinel = [BRSentinel sharedInstance];
  id<BRRendererProvider> provider = [sentinel rendererProvider];
  BRRenderer* renderer = [provider renderer];
  [renderer orderIn];
}

// grab the web view for the flash player
- (WebView*)pluginChildOfView:(WebView*)parentview
{
  NSMutableSet* views = [[[NSMutableSet set] retain] autorelease];
  NSMutableSet* webviews = [[[NSMutableSet set] retain] autorelease];
  WebView* pluginView_;
  [views addObjectsFromArray:[parentview subviews]];
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
    }
  return pluginView_;
}

- (void)makeViewFullscreen:(WebView*)view
{
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
  [view enterFullScreenMode:[NSScreen mainScreen]
                withOptions:options];
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

- (void)playPause{}

@end
