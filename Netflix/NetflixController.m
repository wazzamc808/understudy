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

#import "NetflixAsset.h"
#import "NetflixController.h"
#import "UNDPluginControl.h"
#import "UNDPreferenceManager.h"
#import "UNDPasswordProvider.h"

#import <BRAlertController.h>
#import <BRControllerStack.h>
#import <BRDisplayManager.h>
#import <BREvent.h>
#import <BREventManager.h>
#import <BRMenuSavedState-Private.h>
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
  [pluginControl_ release];
  [asset_ release];
  [player_ release];
  [super dealloc];
}

- (void)_loadVideo
{
  // load the NetflixPlayer to actually play the video
  NSString* path = @"/System/Library/CoreServices/Front Row.app/Contents/Plug"\
  "Ins/frUnderstudy.frappliance/Contents/SharedSupport/NetflixPlayer.app/Conte"\
  "nts/MacOS/NetflixPlayer";

  if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
    NSString* url = [[asset_ url] absoluteString];
    NSArray* args = [[NSArray alloc] initWithObjects:@"--FR", url, nil];
    player_ = [[NSTask launchedTaskWithLaunchPath:path arguments:args] retain];
    [args release];
  } else {
    NSLog (@"NetflixPlayer not available");
  }
  // TODO: need to provide a meaningful error dialog here

  // create an event to mimic a spurious key press, causing Front Row to drop
  // out to the loaded application. this is a reasonable compromize between
  // ordering out or destroying the scene (which doesn't really give up user
  // input to the new app) and terminating FR completely.
  BREvent* ev = [[BREvent alloc] initWithPage:1 usage:136 value:1];
  [[BREventManager sharedManager] postEvent:[ev autorelease]];
}


#pragma mark BR Control

- (void)controlWillActivate
{
  // Save the current stack path here. Note that this must be done before the
  // controller is active so the saved state does not include the video itself.
  [[UNDPreferenceManager sharedInstance] saveMenuState];

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
