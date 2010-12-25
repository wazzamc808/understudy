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

#import <Cocoa/Cocoa.h>

#import "BRSingleton.h"

#import "UnderstudyAsset.h"

@class BRController;

@protocol UNDAssetProvider
- (NSObject<UnderstudyAsset>*)newAssetForContent:(NSDictionary*)content;
/// Returns a unique identifier for this type of provider.
- (NSString*)providerId;
/// Returns a descriptive name for the provider.
- (NSString*)providerName;


/// Returns a (possibly nil) BRController allowing the user to add new assets.
- (BRController*)assetAdditionDialog;
@end

// Standard keys used in asset content descriptions.
extern NSString* UNDAssetProviderNameKey;  // @"provider"
extern NSString* UNDAssetProviderTitleKey; // @"title"
extern NSString* UNDAssetProviderUrlKey;   // @"URL"

@class UNDAddAssetDialog;

@interface UNDAssetFactory : BRSingleton <UNDAssetProvider>
{
  NSMutableDictionary* providers_;
  UNDAddAssetDialog*   addDialog_;
}

/// Returns an asset based on the \param content.
- (NSObject<UnderstudyAsset>*)newAssetForContent:(NSDictionary*)content;

- (void)registerProvider:(NSObject<UNDAssetProvider>*)provider;

/// Returns an array of objects conforming to the UNDAssetProvider protocol.
- (NSArray*)providers;

@end
