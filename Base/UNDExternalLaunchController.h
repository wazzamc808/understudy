//                                                                -*- objc -*-
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

#import <Cocoa/Cocoa.h>

#import "BRTextWithSpinnerController.h"

/// Uses the UNDExternalLauncher to start and monitor an external application.
/// This is useful for starting existing media apps that from Front Row.
@interface UNDExternalLaunchController : BRTextWithSpinnerController
{
@private
  NSTask*   task_;
  NSString* bundleID_;  // Bundle identifier of the external program.
  NSArray*  arguments_; // Command line arguments for the external program.
}

/// Designated initializer. Creates a controller to launch the application with
/// the given bundle id. Title is displayed until the program is launched.
- (id)initWithTitle:(NSString*)title andBundleID:(NSString*)bundleID;

@end
