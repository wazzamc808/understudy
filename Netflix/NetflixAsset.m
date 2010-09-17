//
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

#import "NetflixAsset.h"
#import "NetflixController.h"
#import "UNDNetflixLoadingController.h"

#import <BRImage.h>
#import <BRAlertController.h>

#import <CoreFoundation/CFXMLNode.h>

#include <regex.h>

@interface NetflixAsset (CollectionDiscovery)
- (void)buildCollectionForMedia:(NSString*)mediaID;
@end

@implementation NetflixAsset

#define WATCHURL @"http://www.netflix.com/WiPlayer?movieid=%@"
#define BOXSHOTS @"http://cdn-0.nflximg.com/us/boxshots/large/%@.jpg"

- (id)initWithUrl:(NSString*)url
            title:(NSString*)title
          mediaID:(NSString*)mediaID
      description:(NSString*)description
{
  imageManager_ = [BRImageManager sharedInstance];
  [super init];
  url_ = [[NSURL URLWithString:url] retain];
  description_ = (NSString*) CFXMLCreateStringByUnescapingEntities(NULL,
                                                       (CFStringRef)description,
                                                                   NULL);
  [description_ retain];
  mediaID_ = [mediaID copy];
  title_ = [title copy];
  NSURL* thumburl;
  thumburl = [NSURL URLWithString:[NSString stringWithFormat:BOXSHOTS,mediaID]];
  thumbnailID_ = [[imageManager_ writeImageFromURL:thumburl] retain];
  return self;
}

- (id)initWithXMLElement:(NSXMLElement*) dom
{
  NSString *mediaID, *url, *title;
  [super init];

  NSXMLElement* titleline = [[dom elementsForName:@"title"] objectAtIndex:0];
  title = [[titleline childAtIndex:0] description];
  title = (NSString*) CFXMLCreateStringByUnescapingEntities(NULL,
                                                            (CFStringRef)title,
                                                            NULL);
  NSRange hy = [title rangeOfString:@"- "];
  if( hy.location != NSNotFound )
    title = [[title substringFromIndex:(hy.location+hy.length)] retain];

  NSXMLElement* link = [[dom elementsForName:@"link"] objectAtIndex:0];
  mediaID = [[link stringValue] lastPathComponent];

  url = [NSString stringWithFormat:WATCHURL,mediaID];

  NSString* description = [[[dom elementsForName:@"description"]
                            objectAtIndex:0] stringValue];
  NSRange br = [description rangeOfString:@"<br>"];
  if( br.location != NSNotFound )
    description = [description substringFromIndex: NSMaxRange(br)];
  description = [description stringByReplacingOccurrencesOfString:@"<br>"
                                                       withString:@"\n"];

  [self initWithUrl:url title:title mediaID:mediaID description:description];

  collectionSearchNeeded_ = YES;
  collectionSearchIncomplete_ = YES;
  return self;
}

- (void)dealloc
{
  [collection_ release];
  [description_ release];
  [mediaID_ release];
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
  return [imageManager_ imageNamed:thumbnailID_];
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
  if( !menuitem_ )
  {
    menuitem_ = [BRTextMenuItemLayer menuItem];
    [menuitem_ setTitle:[self title]];
    [menuitem_ retain];
  }
  return menuitem_;
}

- (BRController*)controller
{
  if (collectionSearchIncomplete_) {
    [self startAutoDiscovery];
    UNDNetflixLoadingController* loading;
    loading = [[UNDNetflixLoadingController alloc] init];
    delegate_ = loading;
    return loading;
  }

  NSString* path = @"/Library/Internet Plug-Ins/Silverlight.plugin";
  // if we have a collection (of episodes) return the collection's controller
  if( collection_ ){
    return [collection_ controller];
  }else if( ![[NSFileManager defaultManager] fileExistsAtPath:path] ){
    NSString* title = @"Error";
    NSString* primary = @"Silverlight Not Installed";
    NSString* secondary = @"The Silverlight plugin must be installed in order "\
    "to watch Netflix videos. It can be downloaded from http://silverlight.net";
    BRAlertController* alert = [BRAlertController alertOfType:3
                                                       titled:title
                                                  primaryText:primary
                                                secondaryText:secondary];
    return alert;
  } else {
    return [[NetflixController alloc] initWithAsset:self];
  }
}

#pragma mark Episode Discovery

- (void)startAutoDiscovery
{
  @synchronized(self) {
    if (!collectionSearchNeeded_) return;
    collectionSearchNeeded_ = NO;
  }
  if (mediaID_ == nil) return;
  [self performSelectorInBackground:@selector(buildCollectionForMedia:)
                         withObject:mediaID_];
}

// this method is intended to be invoked on a background thread to fetch a
// (potentially nil) collection of videos
- (void)buildCollectionForMedia:(NSString*)mediaID
{
  NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
  NSString* urlString = @"http://www.netflix.com/WiMovie/";
  urlString = [urlString stringByAppendingFormat:mediaID];
  NSURL* url = [NSURL URLWithString:urlString];
  collection_ = [[UNDNetflixCollection alloc] initWithTitle:title_ forUrl:url];
  if( collection_ )
    menuitem_ = [BRTextMenuItemLayer folderMenuItem];
  else
    menuitem_ = [BRTextMenuItemLayer menuItem];
  [menuitem_ setTitle:[self title]];
  [menuitem_ retain];
  collectionSearchIncomplete_ = NO;
  if (delegate_) [delegate_ assetUpdated:self];
  [pool release];
}

- (void)setDelegate:(id<UNDNetflixAssetUpdateDelegate>)delegate
{
  delegate_ = delegate;
}

@end
