//  Copyright 2011 Jason Brown.
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

#import "DailyShowAsset.h"

#import <TFHpple.h>
#import <TFHppleElement.h>
#import <XPathQuery.h>
#import <BRImage.h>
#import <BRAlertController.h>
#import <DailyShowController.h>

#import <CoreFoundation/CFXMLNode.h>

#include <regex.h>

@implementation DailyShowAsset

- (id)initWithTitle:(NSString*)title description:(NSString*)desc
             forUrl:(NSString*)url forImage:(NSString*)image
{
//  NSLog( @"DailyShowAsset initWithTitle:%@, description: %@, forUrl: %@, forImage: %@", 
//        title, desc, url, image );
  
  startsWithSpinner_ = NO;
  imageManager_ = [BRImageManager sharedInstance];
  [super init];

  title_ = [title retain];
  description_ = [desc retain];
  url_ = [[NSURL URLWithString:url] retain];
  
  // Perform these replacements independently, since there is less change of total failure
  // TODO: use regexp to avoid hardcoding the expected pixel sizes
  image = [image stringByReplacingOccurrencesOfString:@"width=156" withString:@"width=550"];
  image = [image stringByReplacingOccurrencesOfString:@"height=86" withString:@"height=350"];
  image = [image stringByReplacingOccurrencesOfString:@"&crop=true" withString:@""];
  thumbnailID_ = [[imageManager_ writeImageFromURL:[NSURL URLWithString:image]] retain];
//  NSLog( @"DailyShowAsset new image url: %@", image );
//  NSLog( @"DailyShowAsset thumbnailID: %@", thumbnailID_ );
  return self;
}

- (void)dealloc
{
  [description_ release];
  [title_ release];
  [url_ release];
  [super dealloc];
}

- (NSURL*)url{ return url_; }

#pragma mark BRMediaPreviewFactoryDelegate
- (BRMediaType*)mediaPreviewMissingMediaType{ return nil; }
- (BOOL)mediaPreviewShouldShowMetadata{ return YES; }
- (BOOL)mediaPreviewShouldShowMetadataImmediately{ return YES; }


#pragma mark BRMediaAsset
- (NSString*)title{ return title_; }
- (NSString*)titleForSorting{ return [self title]; }
- (NSString*)mediaSummary{ return description_; }
- (NSString*)mediaDescription{ return [self mediaSummary]; }
- (NSString*)mediaURL{ return [url_ description]; }
- (NSString*)thumbnailArtID{ return thumbnailID_; }
- (BRImage*)coverArt{ return [self thumbnailArt]; }
- (BRImage*)thumbnailArt
{ 
  //NSLog( @"thumbnailArt called." );
  return [imageManager_ imageNamed:thumbnailID_];
  //NSLog( @"returning image." );
  //return image;
}
- (BRImage*)coverArtForBookmarkTimeInMS:(unsigned)ms{ return [self coverArt]; }
- (BRMediaType*)mediaType{ return [BRMediaType ytVideo]; }
- (BOOL)hasVideoContent{ return YES; }

- (NSString*)assetID{ return [url_ description]; }
- (BRImage*)coverArtNoDefault{ return [self coverArt]; }

#pragma mark BRImageProvider
- (NSString*)imageID{return nil;}

- (BRLayer<BRMenuItemLayer>*)menuItem
{
  //NSLog( @"menuItem called." );
  if( !menuitem_ )
  {
    menuitem_ = [BRTextMenuItemLayer menuItem];
    [menuitem_ setTitle:[self title]];
    [menuitem_ retain];
    [menuitem_ setWaitSpinnerActive:startsWithSpinner_];
  }
  return menuitem_;  
}

- (BRController*)controller
{
  return [[[DailyShowController alloc] initWithAsset:self] autorelease];
}

@end
