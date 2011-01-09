//                                                                -*- obj -*-
//  Copyright 2010-2011 Kirk Kelsey.
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

#import "UNDAssetFactory.h"
#import "UNDMutableCollection.h"

@implementation UNDMutableCollection

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

- (void)removeAssetAtIndex:(long)index
{
  if (index < 0) return;
  if (!assets_) [self currentAssets];
  if (index >= [assets_ count]) [assets_ removeObjectAtIndex:index];
}

@end
