//
//  Copyright 2009 Kirk Kelsey.
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
#import <BackRow/BRBaseMediaAsset.h>
#import "UnderstudyAsset.h"

@class BRTextMenuItemLayer;
@class BRImageManager;
@class BRMediaType;
@class YouTubeControlDelegate;

@interface YouTubeAsset : BRBaseMediaAsset<UnderstudyAsset> 
{
 @private
  BRTextMenuItemLayer* menuitem_;
  YouTubeControlDelegate* controlDelegate_;
  NSString* description_;
  long duration_;
  BRImageManager* imageManager_;
  NSDate* published_;
  float starrating_;
  NSString* thumbnailID_;
  NSString* title_;
  NSURL* url_;
  BOOL video_;
}

// the init function may return nil if parsing fails
- (id)initWithXMLElement:(NSXMLElement*) dom;
@end
