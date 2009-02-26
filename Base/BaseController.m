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

#import "BaseController.h"
#import "UNDPreferenceManager.h"

#import <BackRow/BRControllerStack.h>
#import <BackRow/BRDisplayManager.h>
#import <BackRow/BREvent.h>
#import <BackRow/BRRenderScene.h>
#import <BackRow/BRSentinel.h>
#import <BackRow/BRSettingsFacade.h>
#import <BackRow/BRWaitSpinnerControl.h>

#import <Carbon/Carbon.h>

@interface BRAppManager : NSObject { }
+ (BRAppManager*)sharedApplication;
- (id)delegate;
@end

@interface BRRenderer{}
- (void)orderIn;
- (void)orderOut;
@end

@implementation BaseController

- (id)init
{
  [super initWithTitle:@"loading" text:@""];
  return self;
}

#pragma mark Transitioning Into/Out of FR
- (void)reveal
{
  BRSentinel* sentinel = [BRSentinel sharedInstance];
  id<BRRendererProvider> provider = [sentinel rendererProvider];
  BRRenderer* renderer = [provider renderer];
  [renderer orderOut];
  // indicate that we don't want the display to go to sleep
  IOReturn err = IOPMAssertionCreate (
                                      kIOPMAssertionTypeNoDisplaySleep,
                                      kIOPMAssertionLevelOn,
                                      &pmAssertion_);
  if( err ) NSLog(@"Error deactivating display sleep: 0x%02X",err);
}

- (void)returnToFR
{
  BRSentinel* sentinel = [BRSentinel sharedInstance];
  id<BRRendererProvider> provider = [sentinel rendererProvider];
  BRRenderer* renderer = [provider renderer];
  [renderer orderIn];
  if( [mainView_ isInFullScreenMode] )
    [mainView_ exitFullScreenModeWithOptions:nil];
  if( [pluginView_ isInFullScreenMode] )
    [pluginView_ exitFullScreenModeWithOptions:nil];
  [mainView_ close];
  [menushield_ close];
  IOReturn err = IOPMAssertionRelease(pmAssertion_);
  if( err ) NSLog(@"Error removing display sleep restriction: 0x%02X",err);
}

#pragma mark Subviews

- (BOOL)hasPluginView
{
  if( pluginView_ ) return YES;
  if( !mainView_ ) return NO;
  
  NSMutableSet* views = [[[NSMutableSet set] retain] autorelease];
  NSMutableSet* webviews = [[[NSMutableSet set] retain] autorelease];
  WebView* view;
  [views addObjectsFromArray:[mainView_ subviews]];
  while( [views count] ){
    view = [views anyObject];
    if( [[view className] isEqual:@"WebNetscapePluginDocumentView"] )
        [webviews addObject:view];
    [views addObjectsFromArray:[view subviews]];
    [views removeObject:view];
  }
  if( [webviews count] < 1 ){
    NSLog(@"could not a find a plugin");
    return NO;
  }else if( [webviews count] > 1 ){
#warning lame heuristic
    pluginView_ = [[webviews anyObject] retain];
    float pluginsize = ([pluginView_ frame].size.height * [pluginView_ frame].size.width);
    // pick the largest plugin view available
    for( view in webviews )
    {
      float viewsize = ([view frame].size.height * [view frame].size.width);
      if( viewsize > pluginsize )
      {
        [pluginView_ autorelease];
        pluginView_ = [view retain];
        pluginsize = ([pluginView_ frame].size.height * [pluginView_ frame].size.width);
      }
    }
    return YES;
  }else{
    pluginView_ = [[webviews anyObject] retain];
    return YES;
  }
}

- (void)_makeViewFullscreen:(WebView*)view
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
  [view enterFullScreenMode:[UNDPreferenceManager screen]
                withOptions:options];
}

- (void)makeMainViewFullscreen
{
  [self _makeViewFullscreen:mainView_];
}

- (void)makePluginFullscreen
{
  if( ![self hasPluginView] ) return;
  [self _makeViewFullscreen:pluginView_];
}

- (void)shieldMenu
{
  if( menushield_ ) return;
  NSRect screenRect = [[UNDPreferenceManager screen] frame];
  screenRect.origin.y = screenRect.size.height - 25;
  screenRect.size.height = 25;
  menushield_ = [[NSWindow alloc] initWithContentRect:screenRect
                                            styleMask:NSBorderlessWindowMask
                                              backing:NSBackingStoreBuffered
                                                defer:NO
                                               screen:[NSScreen mainScreen]];
  [menushield_ setBackgroundColor:[NSColor blackColor]];
  [menushield_ setLevel: CGShieldingWindowLevel() ];
  [menushield_ orderFrontRegardless];
  [menushield_ display];
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
      [settings setSystemVolume:([settings systemVolume]+0.05)];
      return YES;
    case kBRRemoteDownButton:
      settings = [BRSettingsFacade sharedInstance];
      [settings setSystemVolume:([settings systemVolume]-0.05)];
      return YES;
    case kBRRemoteRightButton:
      [self fastForward];
      return YES;
    case kBRRemoteLeftButton:
      [self rewind];
      return YES;
    default:
      return [super brEventAction:event];
  }
}

- (void)sendPluginKeyCode:(int)keyCode withCharCode:(int)charCode
{
  if( ![self hasPluginView] )return;
  EventRecord event; 
  event.what = keyDown; 
  event.message = (keyCode << 8) + charCode;
  event.modifiers = 0;
  [(id)pluginView_ sendEvent:(NSEvent *)&event];
  event.what = keyUp;
  [(id)pluginView_ sendEvent:(NSEvent *)&event];
}

// click on the plugin view at a given point in it's own coordinate space
// (0,0) is top left, but negative values are measured from the bottom/right
- (void)sendPluginMouseClickAtPoint:(NSPoint)point
{
  EventRecord record;
  NSPoint orig = [pluginView_ frame].origin;
  NSSize  size = [pluginView_ frame].size;
  record.modifiers = btnState;
  record.message = 0;
  record.what = mouseDown;
  record.when = TickCount();
  record.where.h = orig.x + point.x;
  record.where.v = orig.y + point.y;
  
  // if a dimension of the point is negative, offset if from the bottom/right
  if( point.x < 0 ) record.where.h += size.width;
  if( point.y < 0 ) record.where.v += size.height;
  
//  NSLog(@"clicking at %d/%d",record.where.h,record.where.v);
//  Point p;
//  GetGlobalMouse(&p);
//  NSLog(@"mouse at %d/%d",p.h,p.v);
  
  [pluginView_ sendEvent:(NSEvent *)&record];  
  record.what = mouseUp;
  record.when = TickCount();
  [pluginView_ sendEvent:(NSEvent *)&record];  
}

#pragma mark Subclasses Should Override
- (void)playPause{}
- (void)fastForward{}
- (void)rewind{}
@end
