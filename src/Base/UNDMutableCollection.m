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
#import "UNDPreferenceManager.h"

@implementation UNDMutableCollection

- (id)initWithTitle:(NSString*)title forContents:(NSMutableArray*)contents
{
  [super initWithTitle:title];
  contents_ = [contents retain];
  return self;
}

- (void)dealloc
{
  [assets_ release];
  [contents_ release];
  [controller_ release];
  [super dealloc];
}

- (NSArray*)currentAssets
{
  // Builds an array of assets based on the dictionaries contained in the
  // original contents array. Mutable copies of the dictionaries are made to
  // allow for later editing.
  if (!assets_) {
    int capacity = [contents_ count];
    assets_ = [[NSMutableArray arrayWithCapacity:capacity] retain];
    NSMutableArray* mutableContents
      = [[[NSMutableArray arrayWithCapacity:capacity] retain] autorelease];
    UNDAssetFactory* assetFactory = [UNDAssetFactory sharedInstance];
    for (NSDictionary* content in contents_) {
      NSMutableDictionary* newContent = [[content mutableCopy] autorelease];
      [assets_
        addObject:[[assetFactory newAssetForContent:newContent] autorelease]];
      [mutableContents addObject:newContent];
    }
    // Replace the contents with the mutable copies.
    [contents_ setArray:mutableContents];
  }
  return assets_;
}

/// If the index if beyond the end of the current list, the asset will
/// simply be added in the final position.
- (void)addAssetWithDescription:(NSDictionary*)description atIndex:(long)index
{
  if (index < 0) return;
  if (!assets_) [self currentAssets];

  UNDAssetFactory* factory = [UNDAssetFactory sharedInstance];
  NSMutableDictionary* content = [[description mutableCopy] autorelease];
  NSObject* asset = [[factory newAssetForContent:content] autorelease];

  if (index > (long)[assets_ count]) index = [assets_ count];

  [assets_ insertObject:asset atIndex:index];
  [contents_ insertObject:content atIndex:index];
  [[UNDPreferenceManager sharedInstance] save];
  [controller_ reloadAssets];
}

- (void)moveAssetFromIndex:(long)from toIndex:(long)to
{
  if (from < 0 || to < 0) return;
  if (from == to) return;
  if (!assets_) [self currentAssets];

  int assetCount = [assets_ count], contentCount = [contents_ count];
  if (assetCount != contentCount) return;
  if (from >= assetCount || to >= assetCount) return;

  NSObject* asset = [assets_ objectAtIndex:from];
  NSObject* content = [contents_ objectAtIndex:from];

  [assets_ removeObjectAtIndex:from];
  [contents_ removeObjectAtIndex:from];

  [assets_ insertObject:asset atIndex:to];
  [contents_ insertObject:content atIndex:to];

  [controller_ reloadAssets];
}

- (void)removeAssetAtIndex:(long)index
{
  if (index < 0) return;
  if (!assets_) [self currentAssets];

  int assetCount = [assets_ count], contentCount = [contents_ count];
  if (assetCount != contentCount) return;
  if (index >= assetCount) return;

  [assets_ removeObjectAtIndex:index];
  [contents_ removeObjectAtIndex:index];
  [[UNDPreferenceManager sharedInstance] save];
  [controller_ reloadAssets];
}

/// Changes the name of the entry at @param index to @param title.
- (void)renameAssetAtIndex:(long)index toTitle:(NSString*)title
{
  if (index < 0) return;
  if (!assets_) [self currentAssets];

  UNDAssetFactory* factory = [UNDAssetFactory sharedInstance];
  NSMutableDictionary* content = [contents_ objectAtIndex:index];
  [content setObject:[[title copy] autorelease]
              forKey:UNDAssetProviderTitleKey];
  NSObject* asset = [[factory newAssetForContent:content] autorelease];

  [assets_ replaceObjectAtIndex:index withObject:asset];
  [[UNDPreferenceManager sharedInstance] save];
  [controller_ reloadAssets];
}

@end
