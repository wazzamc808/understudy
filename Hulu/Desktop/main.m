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

@interface UNDHuluDesktopActivator : NSObject{}
@end

@implementation UNDHuluDesktopActivator
- (void)activate
{
  NSString* source = @"tell application \"System Events\" to activate application \"Hulu Desktop\"";
  NSAppleScript* script = [[NSAppleScript alloc] initWithSource:source];
  NSDictionary* err;
  
  [script executeAndReturnError:&err];
  [self performSelector:@selector(activate) withObject:nil afterDelay:1];
}
@end

int main(int argc, char* argv[])
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  [NSApplication sharedApplication];
  [NSApp hideOtherApplications:NSApp];
  NSTask*   player;
  NSString* path;
  NSArray*  args;
  //CGCaptureAllDisplays();

  // load the Hulu player
  path = @"/Applications/Hulu Desktop.app/Contents/MacOS/Hulu Desktop";
  args = [[NSArray alloc] init];
  player = [[NSTask launchedTaskWithLaunchPath:path arguments:args] retain];

  // once it's launched activate it
  [[[UNDHuluDesktopActivator alloc] init] activate];
  //CGReleaseAllDisplays();

  // once it terminates, restart Front Row
  [player waitUntilExit];
  NSWorkspace* work = [NSWorkspace sharedWorkspace];
  [work launchAppWithBundleIdentifier:@"com.apple.frontrowlauncher"
                              options:NSWorkspaceLaunchDefault
       additionalEventParamDescriptor:[NSAppleEventDescriptor nullDescriptor]
                     launchIdentifier:nil];
  // wait a bit, then die
  [NSThread sleepForTimeInterval:5];
  [pool release];
  return 0;
}
