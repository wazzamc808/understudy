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

#import "Netflix/UNDNetflixSeasonCollection.h"

#import "Netflix/UNDNetflixSeason.h"

@implementation UNDNetflixSeasonCollection

- (id)initWithTitle:(NSString*)title forUrl:(NSURL*)url
{
  self = [super initWithTitle:title];
  if (!self) return nil;

  url_ = [url retain];
  if ([self currentAssets])
    return self;

  [self release];
  return nil;
}

- (void)dealloc
{
  [assets_ release];
  [url_ release];
  [super dealloc];
}

#define WIMOVIE @"http://movies.netflix.com/WiMovie/%@"
- (NSArray*)currentAssets
{
  if (assets_) return assets_;

  NSMutableArray* assets = [[[NSMutableArray alloc] init] autorelease];
  NSError* err;

  NSXMLDocument* doc;
  doc = [[[NSXMLDocument alloc] initWithContentsOfURL:url_
                                              options:NSXMLDocumentTidyHTML
                                                error:&err] autorelease];
  NSXMLElement* root = [doc rootElement];

  // Get the <a data-vid="60037854"> elements
  NSArray *dataVids = [[[root nodesForXPath:@"//@data-vid"
                                      error:nil] retain] autorelease];
  for (NSXMLElement* element in dataVids) {
    NSString* urlString = [NSString stringWithFormat:WIMOVIE, [element stringValue]];
    NSURL* url = [NSURL URLWithString:urlString];
    UNDNetflixSeason* season = [[UNDNetflixSeason alloc] initWithUrl:url];
    if (season) [assets addObject:[season autorelease]];
  }

  [assets_ autorelease];
  if ([assets count]) assets_ = [assets retain];
  else assets_ = nil;

  return assets_;
}

@end
