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
#import "BRMediaMenuController.h"
#import "BRMenuListItemProvider-Protocol.h"
#import "UnderstudyAsset.h"

@class BRTextMenuItemLayer;

@protocol UNDMenuDelegate<UnderstudyAsset>
// Returns an autoreleased array of UnderstudyAsset objects. Feed delegates
// should not load their assests until specifically asked.
- (NSArray*) currentAssets;
@end

@protocol UNDMutableMenuDelegate<UNDMenuDelegate>
- (void)removeAssetAtIndex:(long)index;
- (void)addAssetWithDescription:(NSDictionary*)description atIndex:(long)index;
- (void)renameAssetAtIndex:(long)index toTitle:(NSString*)title;
@end

@interface UNDMenuController : BRMediaMenuController<BRMenuListItemProvider>
{
 @private
  NSArray* assets_;
  NSObject<UNDMenuDelegate>* delegate_;  // delegate is retained by controller
  NSDate* lastrebuild_;
  BOOL mutable_;
  BOOL reloadActive_;           // true when the asset list is being reloaded
  int  height_;                 // how high on the stack this controller is
}

- (id)initWithDelegate:(NSObject<UNDMenuDelegate>*)delegate;

@end
