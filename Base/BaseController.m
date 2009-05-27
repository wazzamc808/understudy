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

#import <BRControllerStack.h>
#import <BRDisplayManager.h>
#import <BREvent.h>
#import <BRRenderer.h>
#import <BRSentinel.h>
#import <BRSettingsFacade.h>

#import <Carbon/Carbon.h>
typedef enum
  {
    MenuButton = 1,
    UpButton,
    DownButton,
    PlayPauseButton,
    LeftButton,
    RightButton
  } ButtonValues;

@protocol BRRendererProvider
- (BRRenderer*)renderer;
@end

@implementation BaseController

- (id)init
{
  [super initWithTitle:@"loading" text:@""];
  return self;
}

// indicate that there has been user activity in order to preven display sleep
- (void)preventSleep
{
  UpdateSystemActivity(UsrActivity);
  [self performSelector:@selector(preventSleep) withObject:nil afterDelay:30];
}

#pragma mark Transitioning Into/Out of FR
- (void)captureDisplays
{
  NSNumber *displayID, *mainID;
  NSScreen* mainScreen = [UNDPreferenceManager screen];
  mainID = [[mainScreen deviceDescription] objectForKey:@"NSScreenNumber"];
  for( NSScreen* screen in [NSScreen screens] ){
    displayID = [[screen deviceDescription] objectForKey:@"NSScreenNumber"];
    if( [displayID compare:mainID] != NSOrderedSame )
      CGDisplayCapture( [displayID intValue]);
  }
}

- (void)reveal
{
  BRSentinel* sentinel = [BRSentinel sharedInstance];
  id<BRRendererProvider> provider = [sentinel rendererProvider];
  BRRenderer* renderer = [provider renderer];
  [renderer orderOut];
  if( ![[UNDPreferenceManager sharedInstance] debugMode] )
    [self captureDisplays];
  [self preventSleep];
}

- (void)returnToFR
{
  CGReleaseAllDisplays();
  // cancel any outstanding calls to [self preventSleep]
  [NSObject cancelPreviousPerformRequestsWithTarget:self];
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
    case PlayPauseButton:
      [self playPause];
      return YES;
      break;
    case UpButton:
      settings = [BRSettingsFacade sharedInstance];
      [settings setSystemVolume:([settings systemVolume]+0.05)];
      return YES;
    case DownButton:
      settings = [BRSettingsFacade sharedInstance];
      [settings setSystemVolume:([settings systemVolume]-0.05)];
      return YES;
    case RightButton:
      [self fastForward];
      return YES;
    case LeftButton:
      [self rewind];
      return YES;
    default:
      return [super brEventAction:event];
  }
}

#pragma mark Subclasses Should Override
- (void)playPause{}
- (void)fastForward{}
- (void)rewind{}
@end
