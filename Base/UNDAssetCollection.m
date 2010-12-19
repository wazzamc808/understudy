//                                                                -*- obj -*-
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

#import <BRTextMenuItemLayer.h>

#import "UNDAssetCollection.h"
#import "UNDAssetFactory.h"

@implementation UNDAssetCollection

- (id)initWithTitle:(NSString*)title forContents:(NSArray*)contents
{
  [super initWithTitle:title];
  contents_ = [contents retain];
  return self;
}

- (void)dealloc
{
  [contents_ release];
  [controller_ release];
  [super dealloc];
}

- (BRController*)controller
{
  if (!controller_)
    controller_ = [[FeedMenuController alloc] initWithDelegate:self];
  return controller_;
}

- (NSArray*)currentAssets
{
  if (!assets_) {
    assets_ = [[NSMutableArray arrayWithCapacity:[contents_ count]] retain];
    UNDAssetFactory* assetFactory = [UNDAssetFactory sharedInstance];
    for (NSDictionary* content in contents_)
      [assets_
        addObject:[[assetFactory newAssetForContent:content] autorelease]];
  }
  return assets_;
}

- (BRLayer<BRMenuItemLayer>*)menuItem
{
  if (!menuItem_) {
    BRTextMenuItemLayer* menuItem = [BRTextMenuItemLayer folderMenuItem];
    [menuItem setTitle:[self title]];
    [menuItem retain];
    menuItem_ = menuItem;
  }
  return menuItem_;
}

@end
