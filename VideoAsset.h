//
//  VideoAsset.h
//  Understudy FR Appliance
//
//  Created by Kirk Kelsey.
//  Copyright 2008. All rights reserved.
//

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
