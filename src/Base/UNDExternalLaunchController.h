//                                                                -*- objc -*-
//  Copyright 2010, 2011 Kirk Kelsey.
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

#import <Cocoa/Cocoa.h>

#import "BRHeaders/BRTextWithSpinnerController.h"

/// Uses the UNDExternalLauncher to start and monitor an external application.
/// This is useful for starting existing media apps from Front Row, but is not
/// appropriate for UNIX style command line programs.
@interface UNDExternalLaunchController : BRTextWithSpinnerController
{
@private
  NSTask*   task_;
  NSString* appName_;       // Application name or path.
  NSString* url_;           // URL to open with the application.
}

/// Designated initializer. Creates a controller to launch the named
/// application. The name parameter should be either a name (without .app
/// extension) or an absolute path (with .app extension). Title is displayed
/// until the program is launched.
- (id)initWithTitle:(NSString*)title forApp:(NSString*)appName;

/// Assigns a url to open with the app.
- (void)setURL:(NSString*)url;

@end
