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

#import "UNDAssetFactory.h"
#import "NetflixFeed.h"

extern NSString* UNDNetflixAssetProviderName;

@interface UNDNetflixAssetProvider : NSObject <UNDAssetProvider>

/// Returns a Netflix related asset based on the given dictionary.
///
/// The content should contain keys @"URL" and @"Title". If the expected keys
/// are not found, or the asset cannot be constructed for any other reason, nil
/// will be returned.
- (NSObject<UnderstudyAsset>*)assetForContent:(NSDictionary*)content;

@end
