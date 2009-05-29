//
//  Copyright 2009 Kirk Kelsey.
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

#import <WebKit/WebKit.h>

#import "AppleRemote.h"
#import "FrontRowKeyboardDevice.h"
#import "RemoteControl.h"
#import "RemoteControlContainer.h"

#import "UNDHuluPlayer.h"

int main(int argc, char* argv[])
{
  [NSApplication sharedApplication];
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSURL* url;
  RemoteControlContainer* controls;
  UNDHuluPlayer* player;

  // the url to load should be the first argument
  if( argc < 1 ) return 1;
  url = [NSURL URLWithString:[NSString stringWithCString:argv[1]]];
  if(!url) return 1;

  player = [[UNDHuluPlayer alloc] init];
  controls = [[RemoteControlContainer alloc] initWithDelegate:player];
  [controls instantiateAndAddRemoteControlDeviceWithClass:[AppleRemote class]];
  [controls instantiateAndAddRemoteControlDeviceWithClass:[FrontRowKeyboardDevice class]];
  [controls startListening:player];

  [player loadURL:url];

  [NSApp run];
  [pool release];
  return 0;
}
