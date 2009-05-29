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
#import "UnderstudyAppliance.h"
#import "UNDPreferenceManager.h"
#import "UNDPasswordProvider.h"

#import <BRControllerStack.h>
#import <BREvent.h>
#import <BREventManager.h>
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
  [player_ release];
  [super dealloc];
}

- (void)_loadVideo
{
  // load the HuluPlayer to actually play the video
  NSString* path = @"/System/Library/CoreServices/Front Row.app/Contents/PlugI"\
    "ns/frUnderstudy.frappliance/Contents/SharedSupport/HuluPlayer.app/Content"\
    "s/MacOS/HuluPlayer";
  NSString* url = [[asset_ url] absoluteString];
  NSArray* args = [[NSArray alloc] initWithObjects:url,nil];
  player_ = [[NSTask launchedTaskWithLaunchPath:path arguments:args] retain];

  // create an event to mimic a spurious key press, causing Front Row to drop
  // out to the loaded application. this is a reasonable compromize between
  // ordering out or destroying the scene (which doesn't really give up user
  // input to the new app) and terminating FR completely.
  BREvent* ev = [[BREvent alloc] initWithPage:1 usage:136 value:1];
  [[BREventManager sharedManager] postEvent:ev];
}


#pragma mark BR Control

- (void)controlWillActivate
{
  [super controlWillActivate];
  [self _loadVideo];
}

- (void)controlWillDeactivate
{
  CGCaptureAllDisplays();
  [self returnToFR];
  [super controlWillDeactivate];
}

@end
