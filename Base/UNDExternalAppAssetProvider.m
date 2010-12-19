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

#import "UNDExternalAppAssetProvider.h"
#import "UNDExternalAppAsset.h"

NSString* UNDExternalAppAssetProviderName = @"externalapp";

NSString* UNDExternalAppAssetKey = @"appname";

@implementation UNDExternalAppAssetProvider

- (NSObject<UnderstudyAsset>*)assetForContent:(NSDictionary*)content
{
  NSString* appname = [content objectForKey:UNDExternalAppAssetKey];
  if (!appname) return nil;
  return [[UNDExternalAppAsset alloc] initWithAppName:appname];
}

- (NSString*)name
{
  return [UNDExternalAppAssetProviderName copy];
}

@end
