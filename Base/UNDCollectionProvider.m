//
//  Copyright 2011 Kirk Kelsey.
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

#import "UNDCollectionProvider.h"
#import "UNDMutableCollection.h"

NSString* UNDCollectionProviderId = @"collection";

static void __attribute__((constructor)) UNDCollectionProvider_init(void)
{
  [[UNDAssetFactory sharedInstance]
      registerProvider:[[[UNDCollectionProvider alloc] init] autorelease]];
}

@implementation UNDCollectionProvider

- (NSObject<UnderstudyAsset>*)newAssetForContent:(NSDictionary*)content
{
  NSString* title = [content objectForKey:UNDAssetProviderTitleKey];
  if (!title) return nil;

  NSMutableArray* assets = [[[content objectForKey:UNDAssetProviderAssetsKey]
                              mutableCopy] autorelease];
  if (!assets) assets = [[[NSMutableArray alloc] init] autorelease];
  // If possible, make the dictionary's assets mutable.
  if ([content respondsToSelector:@selector(setObject:forKey:)])
    [(id)content setObject:assets forKey:UNDAssetProviderAssetsKey];
  return [[UNDMutableCollection alloc] initWithTitle:title forContents:assets];
}

- (NSString*)providerId
{
  return [[UNDCollectionProviderId copy] autorelease];
}

- (NSString*)providerName
{
  return [[@"Asset Collection" copy] autorelease];
}

- (BRController*)assetAdditionDialog
{
  return nil;
}

@end
