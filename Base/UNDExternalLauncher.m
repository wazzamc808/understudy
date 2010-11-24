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

@interface UNDNotificationObserver : NSObject
{
  NSString* bundleID_;
}
- (id)   initWithBundleID:(NSString*)bundleID;
- (void) applicationDidLaunch;
- (void) applicationDidTerminate;
@end

int main(int argc, char* argv[])
{
  if (argc < 2) return 1;

  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  NSString* bundleID = [NSString stringWithCString:argv[1]
                                          encoding:NSASCIIStringEncoding];

  NSWorkspace* work = [NSWorkspace sharedWorkspace];

  // Setup notifications so we know if the application is running.
  UNDNotificationObserver* observer
    = [[UNDNotificationObserver alloc] initWithBundleID:bundleID];

  NSNotificationCenter* notificationCenter = [[work notificationCenter] retain];

  [notificationCenter addObserver:observer
                         selector:@selector(applicationDidTerminate)
                             name:@"NSWorkspaceDidTerminateApplicationNotification"
                           object:nil];

  [notificationCenter addObserver:observer
                         selector:@selector(applicationDidLaunch)
                             name:@"NSWorkspaceDidLaunchApplicationNotification"
                           object:nil];

  // Launch the application.
  BOOL launched =
    [work launchAppWithBundleIdentifier:bundleID
                                options:NSWorkspaceLaunchDefault
         additionalEventParamDescriptor:[NSAppleEventDescriptor nullDescriptor]
                       launchIdentifier:nil];

  if (!launched) {

    NSLog(@"failed to launch application %@", bundleID);

  } else {
    [work hideOtherApplications];
    NSRunLoop* runLoop = [[NSRunLoop mainRunLoop] retain];
    [runLoop run];
  }

  [notificationCenter removeObserver:observer];
  [pool release];
  return 0;
}

@implementation UNDNotificationObserver : NSObject
- (id) initWithBundleID:(NSString*)bundleID
{
  [super init];
  bundleID_ = [bundleID copy];
  return self;
}

- (void) dealloc
{
  [bundleID_ release];
  [super dealloc];
}

- (void) applicationDidLaunch
{
  // We should be setting up shield windows to hide the transition in/out of
  // the external application. At this point they should be hidden.
}

- (void) applicationDidTerminate
{
  bool active = NO;
  NSWorkspace* work = [NSWorkspace sharedWorkspace];

  // Check whether the original application is still running
  NSArray* applications = [work launchedApplications];
  for (NSDictionary* app in applications) {
    NSString* ID = [app objectForKey:@"NSApplicationBundleIdentifier"];
    if ([ID compare:bundleID_] == NSOrderedSame) {
      active=YES;
      break;
    }
  }

  if (active) return;

  // If the application is no longer running then we should return to FR.
  [work launchAppWithBundleIdentifier:@"com.apple.frontrowlauncher"
                              options:NSWorkspaceLaunchDefault
       additionalEventParamDescriptor:[NSAppleEventDescriptor nullDescriptor]
                     launchIdentifier:nil];

  exit(0);
}
@end
