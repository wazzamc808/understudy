//
//  Copyright 2008 Kirk Kelsey.
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

#import "BackRow/BRBaseMediaAsset.h"
#import <BackRow/BRImageManager.h>
#import "BackRow/BRMediaAsset.h"


// class VideoAsset
//
// Represents the attributes of a Hulu Video

@interface VideoAsset : BRBaseMediaAsset<BRMediaAsset> {
 @private
  NSString* title_;
  NSString* series_;
  NSString* description_;
  NSString* credit_;
  NSURL* url_;
  float starrating_;
  long duration_;
  int episode_;
  int season_;
  NSString* episodeInfo_;
  NSDate* airdate_;
  NSDate* added_;
  NSString* thumbnailID_;
  BRImageManager* imageManager_;
}

// Designated initializer. Builds the asset from the provided XML object
// model. Some of the attributes are generic like media:url, but much of it
// is specific to Hulu
- (id)initWithXMLElement:(NSXMLElement*)dom;

// Provides the primary url of the media.
- (NSURL*)url;
// a short identifier for a single episode
- (NSString*)episodeInfo;
@end
