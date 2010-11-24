//
//  Copyright 2010 Kirk Kelsey.
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

#import "UNDExternalLaunchController.h"
#import "BREvent.h"
#import "BREventManager.h"

@implementation UNDExternalLaunchController

- (id)initWithTitle:(NSString*)title andBundleID:(NSString*)bundleID
{
  [super initWithTitle:@"loading" text:title];
  bundleID_ = [bundleID copy];
  return self;
}

- (void)dealloc
{
  [task_ release];
  [bundleID_ release];
  [arguments_ release];
  [super dealloc];
}

- (void)controlWillActivate
{
  // Launch the internal program launcher and leave Front Row.
  NSString* path = @"/System/Library/CoreServices/Front Row.app/Contents" \
    "/PlugIns/frUnderstudy.frappliance/Contents/SharedSupport"            \
    "/UNDExternalLauncher.app/Contents/MacOS/UNDExternalLauncher";

  if (!arguments_)
    arguments_ = [NSArray arrayWithObjects:bundleID_, nil];

  task_ = [[NSTask launchedTaskWithLaunchPath:path
                                    arguments:arguments_] retain];

  // create an event to mimic a spurious key press, causing Front Row to drop
  // out to the loaded application. this is a reasonable compromize between
  // ordering out or destroying the scene (which doesn't really give up user
  // input to the new app) and terminating FR completely.
  BREvent* ev = [[BREvent alloc] initWithPage:1 usage:136 value:1];
  [[BREventManager sharedManager] postEvent:ev];
  [ev release];
}

@end
