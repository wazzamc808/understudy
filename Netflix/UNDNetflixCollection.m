//
//  Copyright 2009-2010 Kirk Kelsey.
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

#import "UNDNetflixCollection.h"
#import "NetflixAsset.h"

@implementation UNDNetflixCollection

- (id)initWithTitle:(NSString*)title forUrl:(NSURL*)url
{
  [super initWithTitle:title];
  url_ = [url retain];

  if ([self currentAssets]) return self;

  [self release];
  return nil;
}

- (void)dealloc
{
  [url_ release];
  [super dealloc];
}

- (NSArray*)currentAssets
{
  if (assets_) return assets_;

  NSMutableArray* assets = [[NSMutableArray alloc] init];
  NSError* err;

  NSXMLDocument* doc;
  NSString* mediaID = [[url_ path] lastPathComponent];
  doc = [[[NSXMLDocument alloc] initWithContentsOfURL:url_
                                              options:NSXMLDocumentTidyHTML
                                                error:&err] autorelease];
  NSXMLElement* movieDiv = nil;
  NSXMLElement* root = [doc rootElement];
  NSArray *items = [[[root nodesForXPath:@"//*[@id='mdp-series']"
                                   error:nil] retain] autorelease];
  if ([items count] > 0)  movieDiv = [items objectAtIndex:0];
  else return nil;

  NSString* seriesClass
  = @"dl[@class='series-mapping']/dd | dl[@class='series-episodes']/dd";

  // find all the instant watch movie nodes
  NSArray *discs = [[[movieDiv nodesForXPath:seriesClass
                                       error:nil] retain] autorelease];

  NSString* seriesButton = @"dl/dd[starts-with(@class,'series-button ep')]";
  for (NSXMLElement* disc in discs)
  {
    NSArray* episodes = [[[disc nodesForXPath:seriesButton
                                       error:nil] retain] autorelease];
    for (NSXMLElement* node in episodes)
    {
      NSString* attr = [[node attributeForName:@"class"] stringValue];
      NSString* episode = [[attr componentsSeparatedByString:@" "] lastObject];
      NSString* titleClass = [NSString stringWithFormat:@"dl/dt[@class='title %@']",
                                       episode];

      NSArray* myid = [disc nodesForXPath:titleClass error:nil];
      NSString* title = [[[[myid lastObject] stringValue] retain] autorelease];

      NSArray* mylink = [node nodesForXPath:@"span/a/@href" error:nil];
      NSString* href = [[[[mylink lastObject] stringValue] retain] autorelease];

      NSString* descPath = [NSString stringWithFormat:@"dl/dd[starts-with(@class,'details %@')]/p", episode];
      NSArray* Desc = [disc nodesForXPath:descPath error:nil];
      NSString* des = [[[[Desc lastObject] stringValue] retain] autorelease];

      // skip the items that are only available on the DVD
      if ([href rangeOfString:@"WiPlayer"].location != NSNotFound
          && href && title && des)
      {
        @try
        {
          NetflixAsset* asset = [[NetflixAsset alloc] initWithUrl:href
                                                            title:title
                                                          mediaID:mediaID
                                                      description:des];
          [assets addObject:asset];
        }
        @catch (NSException *exception)
        {
          NSLog(@"exception: %@",exception);
          NSLog(@"href = %@",href);
        }
      }
    }
  }
  assets_ = [assets retain];
  return assets_;
}

@end
