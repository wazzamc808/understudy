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

#import "BRHeaders/BRMediaMenuController.h"
#import "BRHeaders/BRMenuListItemProvider-Protocol.h"

#import "Base/UNDAsset.h"

@class BRTextMenuItemLayer;

@protocol UNDMenuDelegate<UNDAsset>
// Returns an autoreleased array of UNDAsset objects. Feed delegates
// should not load their assests until specifically asked.
- (NSArray*) currentAssets;
@end

@protocol UNDMutableMenuDelegate<UNDMenuDelegate>
- (void)addAssetWithDescription:(NSDictionary*)description atIndex:(long)index;
- (void)moveAssetFromIndex:(long)from toIndex:(long)to;
- (void)removeAssetAtIndex:(long)index;
- (void)renameAssetAtIndex:(long)index toTitle:(NSString*)title;
@end

@interface UNDMenuController : BRMediaMenuController<BRMenuListItemProvider>
{
 @private
  NSArray* assets_;
  NSObject<UNDMenuDelegate>* delegate_;  // delegate is retained by controller
  NSDate* lastrebuild_;
  BOOL assetsUpdated_;          // True when view needs to be refreshed.
  BOOL mutable_;
  BOOL reloadActive_;           // true when the asset list is being reloaded
  int  height_;                 // how high on the stack this controller is
}

-(id)initWithDelegate:(NSObject<UNDMenuDelegate>*)delegate;
-(void)reloadAssets;

@end
