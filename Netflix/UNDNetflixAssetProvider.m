//
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

#import "UNDNetflixAddDialog.h"
#import "UNDNetflixAssetProvider.h"
#import "UNDNetflixFeed.h"

NSString* UNDNetflixAssetProviderId = @"netflix";

@implementation UNDNetflixAssetProvider

- (NSObject<UnderstudyAsset>*)newAssetForContent:(NSDictionary*)content
{
  NSString* title = [content objectForKey:UNDAssetProviderTitleKey];
  NSURL* url
    = [NSURL URLWithString:[content objectForKey:UNDAssetProviderUrlKey]];
  if (!title || !url) return nil;
  return [[UNDNetflixFeed alloc] initWithTitle:title forUrl:url];
}

- (NSString*)providerId
{
  return [[UNDNetflixAssetProviderId copy] autorelease];
}

- (NSString*)providerName
{
  return [[@"Netflix" copy] autorelease];
}

- (BRController*)assetAdditionDialog
{
  return [[[UNDNetflixAddDialog alloc] init] autorelease];
}


@end
