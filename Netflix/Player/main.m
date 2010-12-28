//
//  Copyright 2009,2010 Kirk Kelsey.
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
//  FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License
//  for more details.
//
//  You should have received a copy of the GNU Lesser General Public License
//  along with Understudy.  If not, see <http://www.gnu.org/licenses/>.

#import <WebKit/WebKit.h>

#import "AppleRemote.h"
#import "FrontRowKeyboardDevice.h"
#import "RemoteControl.h"
#import "RemoteControlContainer.h"

#import "UNDNetflixPlayer.h"

int main(int argc, char* argv[])
{
  [NSApplication sharedApplication];
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSURL* url = nil;
  RemoteControlContainer* controls;
  UNDNetflixPlayer* player;
  BOOL returnToFR = NO;

  int i;
  for (i = 1; i < argc; i++){
    NSString* arg = [NSString stringWithCString:argv[i]
                                       encoding:NSUTF8StringEncoding];
    if ([arg compare:@"--FR"] == NSOrderedSame) returnToFR = YES;
    else url = [NSURL URLWithString:arg];
  }

  if(!url) NSLog (@"NetflixPlayer: no valid URL given", argv[1]);

  player = [[[UNDNetflixPlayer alloc] init] autorelease];
  [player setShouldReturnToFR:returnToFR];

  controls = [[[RemoteControlContainer alloc] initWithDelegate:player] autorelease];
  [controls instantiateAndAddRemoteControlDeviceWithClass:[AppleRemote class]];
  Class keyboardDevice = [FrontRowKeyboardDevice class];
  [controls instantiateAndAddRemoteControlDeviceWithClass:keyboardDevice];
  [controls startListening:player];

  [player loadURL:url];

  [NSApp run];
  [pool release];
  return 0;
}
