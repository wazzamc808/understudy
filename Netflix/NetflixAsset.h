//                                                                -*- objc -*-
//  Copyright 2008-2010 Kirk Kelsey.
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

#import <BRBaseMediaAsset.h>
#import <BRImageManager.h>
#import <BRMediaAsset-Protocol.h>
#import <BRTextMenuItemLayer.h>

#import "BaseUnderstudyAsset.h"
#import "UnderstudyAsset.h"
#import "UNDNetflixCollection.h"

// class NetflixAsset
//
// Represents the attributes of a Netflix Video

@class NetflixAsset;

@protocol UNDNetflixAssetUpdateDelegate
- (void)assetUpdated:(NetflixAsset*)asset;
@end

@interface NetflixAsset : BaseUnderstudyAsset <UnderstudyAsset> {
 @private
  NSString* description_;
  NSString* mediaID_;
  NSURL* url_;
  NSString* thumbnailID_;
  BRImageManager* imageManager_;
  UNDNetflixCollection* collection_;
  id<UNDNetflixAssetUpdateDelegate> delegate_;
  BOOL collectionSearchNeeded_;
  BOOL collectionSearchIncomplete_;
}

// designated initializer
- (id)initWithUrl:(NSString*)url
            title:(NSString*)title
          mediaID:(NSString*)mediaID
      description:(NSString*)description;

- (id)initWithXMLElement:(NSXMLElement*)dom;

// Provides the primary url of the media.
- (NSURL*)url;

- (void)setDelegate:(id<UNDNetflixAssetUpdateDelegate>)delegate;

// Initiates the processes of determining whether this asset refers to a single
// video or a collection of them (e.g. a TV series).
- (void)startAutoDiscovery;

@end
