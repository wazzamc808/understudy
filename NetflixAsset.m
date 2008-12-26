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

#import "NetflixAsset.h"

#import <BackRow/BRImage.h>

#import <CoreFoundation/CFXMLNode.h>

#include <regex.h>

@implementation NetflixAsset

#define WATCHURL @"http://www.netflix.com/WiPlayer?movieid=%@"
#define BOXSHOTS @"http://cdn-0.nflximg.com/us/boxshots/large/%@.jpg"

- (id)initWithXMLElement:(NSXMLElement*) dom
{
  NSString *mediaID, *url;
  NSURL* thumburl;

  imageManager_ = [BRImageManager sharedInstance];
  [super init];
  
  NSXMLElement* titleline = [[dom elementsForName:@"title"] objectAtIndex:0];
  NSString* titlestring = [[titleline childAtIndex:0] description];
  NSRange hy = [titlestring rangeOfString:@"- "];
  if( hy.location != NSNotFound )
    title_ = [[titlestring substringFromIndex:(hy.location+hy.length)] retain];
  else
    title_ = [[titlestring copy] retain];

  NSXMLElement* link = [[dom elementsForName:@"link"] objectAtIndex:0];
  mediaID = [[link stringValue] lastPathComponent];

  url = [NSString stringWithFormat:WATCHURL,mediaID];
  url_ = [[NSURL URLWithString:url] retain];

  thumburl = [NSURL URLWithString:[NSString stringWithFormat:BOXSHOTS,mediaID]];
  thumbnailID_ = [[imageManager_ writeImageFromURL:thumburl] retain];

  NSString* description = [[[dom elementsForName:@"description"] 
                            objectAtIndex:0] stringValue];
  NSRange br = [description rangeOfString:@"<br>"];
  if( br.location != NSNotFound )
    description = [description substringFromIndex: NSMaxRange(br)];
  description_ = (NSString*) CFXMLCreateStringByUnescapingEntities(NULL,(CFStringRef)description,NULL);
  [description_ retain];
  
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
- (float)userStarRating{ return 0.0; }
- (float)starRating{ return 0.0; }
- (long)duration{ return 0.0; }
- (NSString*)mediaURL{ return [url_ description]; }
- (NSString*)thumbnailArtID{ return thumbnailID_; }
- (NSDate*)dateAcquired{ return nil; }
- (NSString*)dateAcquiredString{ return nil; }
- (NSDate*)datePublished{ return nil; }
- (NSString*)datePublishedString{ return nil; }
- (BRImage*)coverArt{ return [self thumbnailArt]; }
- (BRImage*)thumbnailArt
{ 
  //return thumbnail_; 
  return [imageManager_ imageNamed:thumbnailID_];
}
- (BRImage*)coverArtForBookmarkTimeInMS:(unsigned)ms{ return [self coverArt]; }
- (BRMediaType*)mediaType{ return [BRMediaType TVShow]; }
- (BOOL)hasVideoContent{ return YES; }
- (BOOL)isDisabled{ return NO; }
- (NSString*)seriesName{ return nil; }
- (NSString*)seriesNameForSorting{ return nil; }
- (NSString*)broadcaster{ return nil; }
- (NSString*)episodeNumber{ return nil; }
- (unsigned)season{ return 0; }
- (unsigned)episode{ return 0; }
- (BOOL)isInappropriate{ return NO; }

#pragma mark BRMediaAsset (unused)
- (id<BRMediaProvider>) provider{return nil; }
- (NSString*)assetID{ return [url_ description]; }
- (NSString*)artist{ return nil; }
- (NSString*)artistForSorting{ return nil; }
- (NSString*)publisher{ return nil; }
- (NSString*)composer{ return nil; }
- (NSString*)composerForSorting{ return nil; }
- (NSString*)copyright{ return nil; }
- (void)setUserStarRating:(float)value{}
- (NSString*)rating{ return nil; }
- (long)performanceCount{ return 0; }
- (void)incrementPerformanceCount{}
- (void)incrementPerformanceOrSkipCount:(unsigned)elapsedTimeInMS{}
- (BOOL)hasBeenPlayed{ return NO; }
- (void)setHasBeenPlayed:(BOOL)hasBeenPlayed{}
- (NSString*)previewURL{ return nil; }
- (BOOL)hasCoverArt{ return NO; }
- (NSString*)coverArtID{ return nil; }
- (BOOL)isProtectedContent{ return NO; }
- (NSString*)playbackRightsOwner{ return nil; }
- (NSString*)mediaUTI{ return nil; }
- (NSArray*)collections{ return nil; }
- (id<BRMediaCollection>)primaryCollection{ return nil; }
- (NSString*)primaryCollectionTitle{ return nil; }
- (int)primaryCollectionOrder{ return 0; }
- (int)physicalMediaID{ return -1; }
- (NSArray*)genres{ return nil; }
- (BRGenre*)primaryGenre{ return nil; }
- (NSArray*)cast{ return nil; }
- (NSArray*)producers{ return nil; }
- (NSArray*)directors{ return nil; }
- (void)setBookmarkTimeInMS:(unsigned)milliseconds{}
- (void)setBookmarkTimeInSeconds:(unsigned)seconds{}
- (unsigned)bookmarkTimeInMS{ return 0; }
- (unsigned)bookmarkTimeInSeconds{ return 0; }
- (unsigned)startTimeInMS{ return 0; }
- (unsigned)startTimeInSeconds{ return 0; }
- (unsigned)stopTimeInMS{ return 0; }
- (unsigned)stopTimeInSeconds{ return 0; }
- (BRResolution*)resolution{ return [BRResolution ED480p]; }
- (BOOL)canBePlayedInShuffle{ return NO; }
- (BOOL)isLocal{ return NO; }
- (BRImage*)coverArtNoDefault{ return [self coverArt]; }
- (void)skip{ }
- (NSString*)authorName{ return nil; }
- (NSString*)keywords{ return nil; }
- (NSString*)viewCount{ return nil; }
- (NSString*)category{ return nil; }
- (int)grFormat{ return -1;}
- (void)willBeDeleted{ }

#pragma mark BRImageProvider
- (NSString*)imageID{return nil;}
- (void)registerAsPendingImageProvider:(BRImageLoader*)loader
{ NSLog(@"registerAsPendingImageProvider"); }
- (void)loadImage:(BRImageLoader*)loader{ }

@end
