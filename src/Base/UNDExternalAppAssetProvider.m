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

#import "UNDExternalAppAssetProvider.h"

#import "UNDExternalAppAddDialog.h"
#import "UNDExternalAppAsset.h"

NSString* UNDExternalAppAssetProviderId = @"externalapp";

NSString* UNDExternalAppAssetKey = @"appname";

static void __attribute__((constructor)) UNDExternalAppProvider_init(void)
{
  UNDAssetFactory* factory = [UNDAssetFactory sharedInstance];
  id provider = [[[UNDExternalAppAssetProvider alloc] init] autorelease];
  [factory registerProvider:provider];
}

@implementation UNDExternalAppAssetProvider

- (NSObject<UNDAsset>*)newAssetForContent:(NSDictionary*)content
{
  NSString* appname = [content objectForKey:UNDExternalAppAssetKey];
  if (!appname) return nil;
  return [[UNDExternalAppAsset alloc] initWithAppName:appname];
}

- (NSString*)providerId
{
  return [[UNDExternalAppAssetProviderId copy] autorelease];
}

/// Returns nil (this provider shouldn't appear in the menu).
- (NSString*)providerName
{
  return @"External Application";
}

/// Returns nil. An add dialog needs to be implemented for external apps.
- (BRController*)assetAdditionDialog
{
  return [[[UNDExternalAppAddDialog alloc] init] autorelease];
}

@end
