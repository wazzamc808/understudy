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
  NSString* app_;
}
- (id)   initWithApp:(NSString*)app;
- (void) applicationDidLaunch:(NSNotification*)notification;
- (void) applicationDidTerminate:(NSNotification*)notification;
@end

// The command line arguments should be
// 1) Either:
//  a) The name of an app (e.g. Safari)
//  b) He complete path to an app (e.g. /Applications/Safari.app)
// 2) A url for that app to open [optionally]
int main(int argc, char* argv[])
{
  if (argc < 2) return 1;

  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  NSString* appName = [NSString stringWithCString:argv[1]
                                         encoding:NSASCIIStringEncoding];

  NSString* url = nil;
  if (argc > 2)
    url = [NSString stringWithCString:argv[2] encoding:NSASCIIStringEncoding];

  NSWorkspace* work = [NSWorkspace sharedWorkspace];

  // Setup notifications so we know if the application is running.
  UNDNotificationObserver* observer
    = [[UNDNotificationObserver alloc] initWithApp:appName];

  NSNotificationCenter* notificationCenter = [[work notificationCenter] retain];

  [notificationCenter addObserver:observer
                         selector:@selector(applicationDidTerminate:)
                             name:@"NSWorkspaceDidTerminateApplicationNotification"
                           object:nil];

  [notificationCenter addObserver:observer
                         selector:@selector(applicationDidLaunch:)
                             name:@"NSWorkspaceDidLaunchApplicationNotification"
                           object:nil];

  // Launch the application.
  BOOL launched;
  if (url) launched = [work openFile:url withApplication:appName];
  else launched = [work launchApplication:appName];

  if (!launched) {
    NSLog(@"failed to launch application %@", appName);
  } else {
    NSRunLoop* runLoop = [[NSRunLoop mainRunLoop] retain];
    [runLoop run];
  }

  [notificationCenter removeObserver:observer];
  [pool release];
  return 0;
}

@implementation UNDNotificationObserver : NSObject
- (id) initWithApp:(NSString*)app
{
  [super init];
  app_ = [app copy];
  return self;
}

- (void) dealloc
{
  [app_ release];
  [super dealloc];
}

- (void) applicationDidLaunch:(NSNotification*)notification
{
  // We should be setting up shield windows to hide the transition in/out of
  // the external application. At this point they should be hidden.
}

- (void) applicationDidTerminate:(NSNotification*)notification
{
  bool found = NO;

  NSDictionary* userInfo = [[[notification userInfo] retain] autorelease];
  NSString *applicationName, *applicationPath;

  // OS 10.6 stores a NSRunningApplication in the user info.
  applicationName = [userInfo objectForKey:@"NSApplicationName"];
  applicationPath = [userInfo objectForKey:@"NSApplicationPath"];

  // The app might represented by the complete path or the name.
  if ([applicationName compare:app_] == NSOrderedSame) found = YES;
  else if ([applicationPath compare:app_] == NSOrderedSame) found = YES;

  if (!found) return;

  // If the application is no longer running then we should return to FR.
  NSWorkspace* work = [NSWorkspace sharedWorkspace];
  [work launchAppWithBundleIdentifier:@"com.apple.frontrowlauncher"
                              options:NSWorkspaceLaunchDefault
       additionalEventParamDescriptor:[NSAppleEventDescriptor nullDescriptor]
                     launchIdentifier:nil];

  exit(0);
}
@end
