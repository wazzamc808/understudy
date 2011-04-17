//
//  Copyright 2009-2011 Kirk Kelsey.
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

#import <BRImageManager.h>
#import <BRTextMenuItemLayer.h>

#import "UNDMenuController.h"
#import "UNDYouTubeAsset.h"
#import "UNDYouTubeFeed.h"
#import "UNDYouTubeController.h"

@class BRImage;

@interface UNDYouTubeAsset (Parsing)
- (void)buildFromId:(NSXMLElement*)idtag;
- (void)parseMediaGroup:(NSXMLElement*)media;
- (void)setThumbnailFromUrl:(NSString*)url;
@end

static NSString* elementForString(NSXMLElement* xml, NSString* string)
{
  NSArray* elements = [xml elementsForName:string];
  if (![elements count]) return nil;
  return [elements objectAtIndex:0];
}

@implementation UNDYouTubeAsset

- (id)initWithXMLElement:(NSXMLElement*)dom
{
  NSArray* titles = [dom elementsForName:@"title"];
  if (![titles count]) return nil;

  NSXMLElement* titleXML = [titles objectAtIndex:0];
  NSString* title = [[titleXML childAtIndex:0] stringValue];
  title = [title stringByReplacingOccurrencesOfString:@"Videos published by :"
                                           withString:@""];

  self = [super initWithTitle:title];

  // Some YouTube feeds contain other feeds, some contain videos. We make the
  // distinction here, at the asset level.
  NSArray* categories = [dom elementsForName:@"category"];
  if (![categories count]) return nil;

  NSXMLElement* category = [categories objectAtIndex:0];
  NSString* term = [[category attributeForName:@"term"] stringValue];

  if ([term hasSuffix:@"video"] || [term hasSuffix:@"favorite"]) {
    isVideo_ = TRUE;
    // depending on the feed, the video |entry| will be structured differently
    // those with a media:group are easier to work with
    NSArray* mediagroups = [dom elementsForName:@"media:group"];
    if ([mediagroups count])
      [self parseMediaGroup:[mediagroups objectAtIndex:0]];
    else
      [self buildFromId:[[dom elementsForName:@"id"] lastObject]];
  } else {
    NSArray* contents = [dom elementsForName:@"content"];
    if (![contents count]) return nil;
    NSXMLElement* content = [contents objectAtIndex:0];
    isVideo_ = FALSE;
    NSString* src = [[content attributeForName:@"src"] stringValue];
    url_ = [[NSURL URLWithString:src] retain];
    // feeds may have a thumbnail
    NSXMLElement* thumbnail;
    thumbnail = [[dom elementsForName:@"media:thumbnail"] lastObject];
    if (thumbnail) {
      [self setThumbnailFromUrl:[[thumbnail attributeForName:@"url"]
                                  stringValue]];
    }
  }
  return self;
}

- (void)dealoc
{
  [feedDelegate_ release];
  [description_ release];
  [published_ release];
  [thumbnailID_ release];
  [url_ release];
  [videoID_ release];
}

// in feeds that don't use the media:group, we try to parse information from
// the content element of each feed entry. much less information is provided
- (void)buildFromId:(NSXMLElement*)idtag;
{
  if (!idtag) return;
  NSString* mediaid = [idtag stringValue];
  NSRange range = [mediaid rangeOfString:@"video:"];
  if (range.location == NSNotFound) return;

  mediaid = [mediaid substringFromIndex:NSMaxRange(range)];
  range = [mediaid rangeOfString:@":"];
  if (range.location != NSNotFound)
    mediaid = [mediaid substringToIndex:range.location];
  url_ = [[NSURL URLWithString:[@"http://www.youtube.com/watch?v="
                                   stringByAppendingString:mediaid]] retain];
  NSString* thumbnail
    = [NSString stringWithFormat:@"http://i.ytimg.com/vi/%@/1.jpg", mediaid];
  [self setThumbnailFromUrl:thumbnail];

  videoID_ = [mediaid retain];
}

- (void)parseMediaGroup:(NSXMLElement*)media
{
  NSLog(@"parseMediaGroup");
  NSXMLElement* xml;
  NSXMLNode* attribute;

  title_ = [elementForString(media, @"media:title") retain];
  description_ = [elementForString(media, @"yt:description") retain];
  url_ = [elementForString(media, @"media:player") retain];

  // YT often has multiple thumbnails. we could provide them as a parade, or
  // make them available for
  xml = [[media elementsForName:@"media:thumbnail"] objectAtIndex:0];
  attribute = [xml attributeForName:@"url"];
  [self setThumbnailFromUrl:[attribute stringValue]];
  xml = [[media elementsForName:@"yt:duration"] objectAtIndex:0];
  duration_ = [[[xml attributeForName:@"seconds"] stringValue] intValue];
  xml = [[media elementsForName:@"gd:rating"] objectAtIndex:0];
  starrating_ = [[[xml attributeForName:@"average"] stringValue] floatValue];
}

- (BRController*)controller
{
  if (isVideo_)
    return [[[UNDYouTubeController alloc] initWithAsset:self] autorelease];

  if (!feedDelegate_)
      feedDelegate_ = [[UNDYouTubeFeed alloc] initWithTitle:[self title]
                                                     forUrl:url_];

  return [feedDelegate_ controller];
}

- (void)setThumbnailFromUrl:(NSString*)urlString
{
  NSURL* url = [NSURL URLWithString:urlString];
  BRImageManager* manager = [BRImageManager sharedInstance];
  thumbnailID_ = [[manager writeImageFromURL:url] retain];
}

- (NSString*)assetID{ return [url_ description]; }
- (NSString*)titleForSorting{ return [self title]; }
- (NSString*)mediaSummary{ return description_; }
- (NSString*)mediaDescription{ return description_; }
- (float)starRating{ return starrating_; }
- (long)duration{ return duration_; }
- (NSString*)mediaURL{ return [url_ description]; }
- (BOOL)hasCoverArt{ return YES; }
- (NSString*)coverArtID{ return thumbnailID_; }
- (NSString*)thumbnailArtID{ return thumbnailID_; }
- (BRImage*)coverArt{ return [self thumbnailArt]; }
- (BRImage*)thumbnailArt
{
  return [[BRImageManager sharedInstance] imageNamed:thumbnailID_];
}
- (BRMediaType*)mediaType{ return [BRMediaType ytVideo]; }
- (NSDate*)datePublished{ return published_; }
- (NSString*)datePublishedString{ return [published_ description]; }
- (NSString*)videoID{ return videoID_; }

@end
