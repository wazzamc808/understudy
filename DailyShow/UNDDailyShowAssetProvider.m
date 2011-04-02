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
//  FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License
//  for more details.
//
//  You should have received a copy of the GNU Lesser General Public License
//  along with Understudy. If not, see <http://www.gnu.org/licenses/>.

#import "DailyShowAddDialog.h"
#import "DailyShowFullEpisodesFeed.h"
#import "UNDDailyShowAssetProvider.h"

NSString* UNDDailyShowAssetProviderId = @"dailyshow";

@implementation UNDDailyShowAssetProvider

- (NSObject<UNDAsset>*)newAssetForContent:(NSDictionary*)content
{
  NSString* title = [content objectForKey:UNDAssetProviderTitleKey];
  NSURL* url
    = [NSURL URLWithString:[content objectForKey:UNDAssetProviderUrlKey]];
  if (!title || !url) return nil;
  return [[DailyShowFullEpisodesFeed alloc] initWithTitle:title forUrl:url];
}

- (NSString*)providerId
{
  return [[UNDDailyShowAssetProviderId copy] autorelease];
}

- (NSString*)providerName
{
  return [[@"Daily Show" copy] autorelease];
}

- (BRController*)assetAdditionDialog
{
  return [[[DailyShowAddDialog alloc] init] autorelease];
}

@end
