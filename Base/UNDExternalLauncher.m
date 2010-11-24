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

int main(int argc, char* argv[])
{
  if (argc < 2) return 1;

  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  NSString *bundleID = [NSString stringWithCString:argv[1]
                                          encoding:NSASCIIStringEncoding];

  NSWorkspace* work = [NSWorkspace sharedWorkspace];

  [work hideOtherApplications];
  [work launchAppWithBundleIdentifier:bundleID
                              options:NSWorkspaceLaunchDefault
       additionalEventParamDescriptor:[NSAppleEventDescriptor nullDescriptor]
                     launchIdentifier:nil];


  // Loop until we don't find the application among those running. Once
  // we are no longer targeting 10.5, this loop should be changed to use
  // NSRunningApplication and get the active application directly.
  bool active;
  do {
    active = NO;
    [NSThread sleepForTimeInterval:1];
    NSArray* applications = [work launchedApplications];
    for (NSDictionary* app in applications) {
      NSString* ID = [app objectForKey:@"NSApplicationBundleIdentifier"];
      if ([ID compare:bundleID] == NSOrderedSame) active=YES;
    }
  } while(active);

  [work launchAppWithBundleIdentifier:@"com.apple.frontrowlauncher"
                              options:NSWorkspaceLaunchDefault
       additionalEventParamDescriptor:[NSAppleEventDescriptor nullDescriptor]
                     launchIdentifier:nil];

  // wait a bit, then die
  [NSThread sleepForTimeInterval:5];

  [pool release];
  return 0;
}
