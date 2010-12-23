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

#import "UNDAddAssetDialog.h"
#import "UNDAssetFactory.h"
#import "UNDUnknownAsset.h"

@implementation UNDAssetFactory

static NSString* kAssetFactoryName = @"factory";

NSString* UNDAssetProviderNameKey  = @"provider";
NSString* UNDAssetProviderTitleKey = @"title";
NSString* UNDAssetProviderUrlKey   = @"URL";

- (id)init
{
  providers_ = [[NSMutableDictionary alloc] init];
  [self registerProvider:self];
  return self;
}

UNDAssetFactory* singleton_;
+ (id)singleton
{
  return singleton_;
}

+ (void)setSingleton:(UNDAssetFactory*)value
{
  singleton_ = value;
}

- (void)dealloc
{
  [providers_ release];
  [super dealloc];
}

- (NSObject<UNDAssetProvider>*)providerNamed:(NSString*)name
{
  return [providers_ objectForKey:name];
}

- (NSArray*)providers
{
  return [providers_ allValues];
}

- (void)registerProvider:(NSObject<UNDAssetProvider>*)provider
{
  [providers_ setObject:provider forKey:[provider name]];
}

/// An asset is always provided, though it may be a simple placeholder if the
/// content does not indicate a known provider.
- (NSObject<UnderstudyAsset>*)newAssetForContent:(NSDictionary*)content
{
  NSObject<UNDAssetProvider>* provider
    = [self providerNamed:[content objectForKey:UNDAssetProviderNameKey]];
  NSObject<UnderstudyAsset>* asset = [provider newAssetForContent:content];
  if (!asset) asset = [[UNDUnknownAsset alloc] initWithContents:content];
  return asset;
}

- (NSString*)name
{
  return kAssetFactoryName;
}

/// Returns nil.
- (BRController*)assetAdditionDialog
{
  return nil;
}

@end
