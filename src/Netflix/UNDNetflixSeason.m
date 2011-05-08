//
//  Copyright 2011 Kirk Kelsey.
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
//  FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License
//  for more details.
//
//  You should have received a copy of the GNU Lesser General Public License
//  along with Understudy. If not, see <http://www.gnu.org/licenses/>.


#import "Netflix/UNDNetflixSeason.h"

#import <Foundation/NSCharacterSet.h>
#import <BRHeaders/BRImage.h>

#import "Netflix/BRImageManager+Netflix.h"
#import "Netflix/UNDNetflixAsset.h"

@implementation UNDNetflixSeason

- (id)initWithMediaId:(NSString*)mediaId
{
  NSString* urlString = [@"http://movies.netflix.com/WiMovie/"
                            stringByAppendingString:mediaId];
  NSURL* url = [NSURL URLWithString:urlString];

  NSMutableArray* assets = [[[NSMutableArray alloc] init] autorelease];
  NSError *err;
  NSString *show = @"", *season = @"Season ?";;

  NSXMLDocument* doc;
  doc = [[[NSXMLDocument alloc] initWithContentsOfURL:url
                                              options:NSXMLDocumentTidyHTML
                                                error:&err] autorelease];
  NSXMLElement* root = [doc rootElement];

  // Find the H2 element with 'title' class.
  NSArray* titleH2 = [[[root nodesForXPath:@"//h2[@class='title']"
                                     error:nil] retain] autorelease];
  NSCharacterSet* charSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
  if ([titleH2 count]) {
    NSXMLNode* node = [titleH2 objectAtIndex:0];
    show = [[node stringValue] stringByTrimmingCharactersInSet:charSet];
  }

  // Find <li class="seasonItem selected">
  NSArray* selectedSeason
    = [[[root nodesForXPath:@"//li[@class='seasonItem selected']/a"
                      error:nil] retain] autorelease];
  if ([selectedSeason count]) {
    NSXMLNode* node = [selectedSeason objectAtIndex:0];
    season = [[node stringValue] stringByTrimmingCharactersInSet:charSet];
  }

  NSArray* episodeNodes = [[[root nodesForXPath:@"//ul[@class='episodeList']/li"
                                          error:nil] retain] autorelease];
  for (NSXMLNode* episode in episodeNodes) {
    UNDNetflixAsset* asset
      = [[[UNDNetflixAsset alloc] initWithEpisodeXMLNode:episode]
          autorelease];
    if (asset) [assets addObject:asset];
  }

  self = [super initWithTitle:[NSString stringWithFormat:@"%@ - %@",
                                        show, season]];

  if (![assets count]) {
    [self release];
    return nil;
  }

  assets_ = [assets retain];
  image_  = [[[BRImageManager sharedInstance]
               imageNameFromNetflixMediaId:mediaId] retain];
  season_ = [season copy];
  show_ = [show copy];

  return self;
}

- (void)dealloc
{
  [assets_ release];
  [image_ release];
  [season_ release];
  [show_ release];
  [super dealloc];
}

- (NSArray*)currentAssets
{
  return assets_;
}

- (BRImage*)coverArt
{
  return [[BRImageManager sharedInstance] imageNamed:image_];
}

@end
