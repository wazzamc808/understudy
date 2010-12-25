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
  NSString* app_;               // The app name we're looking for.
  BOOL frActive_;               // True when FR is active.
  BOOL hasAppKey_;              // Are we working with NSRunningApplication.
}
- (id)   initWithApp:(NSString*)app;
- (void) applicationDidDeactivate:(NSNotification*)notification;
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
    = [[[UNDNotificationObserver alloc] initWithApp:appName] autorelease];

  NSNotificationCenter* notificationCenter
    = [[[work notificationCenter] retain] autorelease];

  [notificationCenter addObserver:observer
                         selector:@selector(applicationDidTerminate:)
                             name:@"NSWorkspaceDidTerminateApplicationNotification"
                           object:nil];

  [notificationCenter addObserver:observer
                         selector:@selector(applicationDidLaunch:)
                             name:@"NSWorkspaceDidLaunchApplicationNotification"
                           object:nil];

  [notificationCenter addObserver:observer
                         selector:@selector(applicationDidDeactivate:)
                             name:@"NSWorkspaceDidDeactivateApplicationNotification"
                           object:nil];

  // [work hideOtherApplications];

  // Launch the application.
  BOOL launched;
  if (url) launched = [work openFile:url withApplication:appName];
  else launched = [work launchApplication:appName];

  if (!launched) {
    NSLog(@"failed to launch application %@", appName);
  } else {
    NSRunLoop* runLoop = [[[NSRunLoop mainRunLoop] retain] autorelease];
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

  NSDictionary* active = [[NSWorkspace sharedWorkspace] activeApplication];
  id runningApp = [active objectForKey:@"NSWorkspaceApplicationKey"];
  if (runningApp
      && [runningApp respondsToSelector:@selector(bundleIdentifier)])
  {
    hasAppKey_ = YES;
    NSString* bundleId = (NSString*)[runningApp bundleIdentifier];
    if ([bundleId compare:@"com.apple.frontrow"] == NSOrderedSame)
      frActive_ = YES;
  }

  return self;
}

- (void) dealloc
{
  [app_ release];
  [super dealloc];
}

/// Attempts to bring the app forward. This method can safely be called
/// multiple times (and is - once when we know FR is done and once when we know
/// the app has launched).
- (void) activateApp
{
  NSString* format = @"tell application \"%@\" to activate";
  NSString* source = [NSString stringWithFormat:format, app_];

  NSAppleScript* script =
    [[[NSAppleScript alloc] initWithSource:source] autorelease];
  NSDictionary* err = nil;

  [script executeAndReturnError:&err];

  if (err) NSLog(@"activation error %@", err);
}

- (BOOL) applicationMatches:(NSNotification*)notification
{
  NSDictionary* userInfo = [[[notification userInfo] retain] autorelease];
  NSString *applicationName, *applicationPath;

  // OS 10.6 stores a NSRunningApplication in the user info.
  applicationName = [userInfo objectForKey:@"NSApplicationName"];
  applicationPath = [userInfo objectForKey:@"NSApplicationPath"];

  // The app might represented by the complete path or the name.
  if ([applicationName compare:app_] == NSOrderedSame) return YES;
  if ([applicationPath compare:app_] == NSOrderedSame) return YES;

  return NO;
}

- (void) applicationDidDeactivate:(NSNotification*)notification
{
  if (!hasAppKey_) return;
  if (!frActive_) return;

  // Look for front row deactivating
  id runningApp = [[notification userInfo]
                    objectForKey:@"NSWorkspaceApplicationKey"];
  if (!runningApp) return;
  if (![runningApp respondsToSelector:@selector(bundleIdentifier)]) return;

  NSString* bundleId = (NSString*)[runningApp bundleIdentifier];
  if ([bundleId compare:@"com.apple.frontrow"] == NSOrderedSame) {
    frActive_ = NO;
    [self activateApp];
  }
}

- (void) applicationDidLaunch:(NSNotification*)notification
{
  if (![self applicationMatches:notification]) return;

  // If FR is active, we can't activate anything else.
  if (!frActive_) [self activateApp];

  // If we don't get NSRunningApplication information (OS 10.6) then we won't
  // know when FR has deactivated. In that case, wait a while and try again.
  if (!hasAppKey_) {
    [NSThread sleepForTimeInterval:5];
    [self activateApp];
  }

  // We should be setting up shield windows to hide the transition in/out of
  // the external application. At this point they should be hidden.
}

- (void) applicationDidTerminate:(NSNotification*)notification
{
  NSWorkspace* work = [NSWorkspace sharedWorkspace];

  if (![self applicationMatches:notification]) return;

  // If the application is no longer running then we should return to FR.
  [work launchAppWithBundleIdentifier:@"com.apple.frontrowlauncher"
                              options:NSWorkspaceLaunchDefault
       additionalEventParamDescriptor:[NSAppleEventDescriptor nullDescriptor]
                     launchIdentifier:nil];

  [[work notificationCenter] removeObserver:self];
  exit(0);
}

@end
