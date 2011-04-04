//
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

#import "UNDiPlayerAddDialog.h"
#import "UNDiPlayerAssetProvider.h"
#import "UNDiPlayerFeed.h"

NSString* UNDiPlayerAssetProviderId = @"bbciplayer";

static void __attribute__((constructor)) UNDiPlayerAssetProvider_init(void)
{
  UNDAssetFactory* factory = [UNDAssetFactory sharedInstance];
  id provider = [[[UNDiPlayerAssetProvider alloc] init] autorelease];
  [factory registerProvider:provider];
}

@implementation UNDiPlayerAssetProvider

- (NSObject<UNDAsset>*)newAssetForContent:(NSDictionary*)content
{
  NSString* title = [content objectForKey:UNDAssetProviderTitleKey];
  NSURL* url
    = [NSURL URLWithString:[content objectForKey:UNDAssetProviderUrlKey]];
  if (!title || !url) return nil;
  return [[UNDiPlayerFeed alloc] initWithTitle:title forUrl:url];
}

- (NSString*)providerId
{
  return [[UNDiPlayerAssetProviderId copy] autorelease];
}

- (NSString*)providerName
{
  return [[@"BBC iPlayer" copy] autorelease];
}

- (BRController*)assetAdditionDialog
{
  return [[[UNDiPlayerAddDialog alloc] init] autorelease];
}

@end
