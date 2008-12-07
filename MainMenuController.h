//
//  Copyright 2008 Kirk Kelsey.
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

#import <BackRow/BRMediaMenuController.h>
#import <BackRow/BROptionDialog.h>
#import <BackRow/BRTextEntryController.h>

// class MainMenuController
//
// The primary window returned by the appliance controller. Use the
// sharedInstance method to access the menu singleton rather than init (which 
// is the designated initializer.

@interface MainMenuController : BRMediaMenuController
<BRMenuListItemProvider, BRTextEntryDelegate> 
{
 @private
  NSMutableArray* items_;
  NSMutableArray* feeds_;
  NSMutableDictionary* controllers_;
  BRTextEntryController* addController_;
  BROptionDialog* removeDialog_;
  NSString* newfeed_;
}

// Singleton access
+ (MainMenuController*)sharedInstance;

@end
