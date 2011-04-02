//                                                                -*- objc -*-
//  Copyright 2009-2011 Kirk Kelsey.
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

#import <BRSingleton.h>

@interface UNDPreferenceManager : NSObject
{
@private
  /// Array of dictionaries representing <UnderstudyAsset> assets.
  NSMutableArray* assets_;
  // menu state used to restore selections after external player
  NSDictionary* menuState_;

  BOOL huluFSAlerted_;
  BOOL alertsDisabled_;
  BOOL debugMode_;
  NSMutableSet* subscribers_;
}

@property(nonatomic) BOOL huluFSAlerted;
@property(nonatomic) BOOL alertsDisabled;
@property(nonatomic) BOOL debugMode;

+ (UNDPreferenceManager*)sharedInstance;
+ (NSScreen*)screen;
+ (NSString*)accountForService:(NSString*)service;
+ (BOOL)alertsAreDisabled;

- (NSMutableArray*)assetDescriptions;

// The menu state should be saved as it should later be used (e.g. before
// pushing the final controller). The menu state may be nil if nothing should
// be restored.
- (void)clearMenuState;
- (void)saveMenuState;
- (NSDictionary*)savedMenuState;

- (void)load;
- (void)save;
@end
