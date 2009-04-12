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

#import "UNDNetflixCollection.h"
#import "NetflixAsset.h"

@implementation UNDNetflixCollection

- (id)initWithTitle:(NSString*)title forUrl:(NSURL*)url
{
  [super init];
  title_ = [title copy];
  url_ = [url retain];
  if( [self currentAssets] == nil )
  {
    [self release];
    return nil;
  }else{
    return self;
  }
}

- (void)dealloc
{
  [menuItem_ release];
  [title_ release];
  [url_ release];
  [super dealloc];
}

- (NSArray*)currentAssets
{
  if( assets_ ) return assets_;
  
  NSMutableArray* assets = [[NSMutableArray alloc] init];
  NSError* err;
  
  NSXMLDocument* doc;
  NSString* mediaID = [[url_ path] lastPathComponent];
  doc = [[[NSXMLDocument alloc] initWithContentsOfURL:url_
                                              options:NSXMLDocumentTidyHTML
                                                error:&err] autorelease];
  NSXMLElement* movieDiv = nil;
  NSXMLElement* root = [doc rootElement];
  NSArray *items = [[[root nodesForXPath:@"//*[@id='mdpSeriesEpisodes']"  
                                   error:nil] retain] autorelease];
  if( [items count] > 0 )  movieDiv = [items objectAtIndex:0];
  else return nil;

  // find all the instant watch movie nodes
  NSString* path = @"//div[@class='movie seriesMember seriesMemberShowLength']";
  items = [doc nodesForXPath:path  error: nil];
  int icount = [items count];
  int j;
  for (j=0; j < icount; j++) {
    NSXMLElement* node = [items objectAtIndex:j];
    
    NSArray* myid = [node nodesForXPath:@"span[@class='title']" error:nil];
    NSString* _title = [[myid objectAtIndex: 0 ] stringValue];
    
    NSArray* mylink = [node nodesForXPath:@"span/span/span/span/a/@href" error:nil];
    NSString* _href = [[mylink objectAtIndex: 0 ] stringValue];  
    
    NSArray* myDes = [node nodesForXPath:@"div[@class='episodeDetails']" error:nil];
    NSString* _des = [[myDes objectAtIndex: 0 ] stringValue];  
    
    // skip the items that are only available on the DVD
    if( [_href rangeOfString:@"WiPlayer"].location != NSNotFound )
    {
      NetflixAsset* asset = [[NetflixAsset alloc] initWithUrl:_href
                                                        title:_title 
                                                      mediaID:mediaID
                                                  description:_des];
      [assets addObject:asset];
    }
  }
  assets_ = [assets retain];
  return assets_;
}

- (NSString*)title{ return title_; }
- (BRLayer<BRMenuItemLayer>*)menuItem
{
  if( !menuItem_ ){
    menuItem_ = [BRTextMenuItemLayer folderMenuItem];
    [menuItem_ setTitle:[self title]];
    [menuItem_ retain];
  }
  return menuItem_;
}

- (BRController*)controller
{
  if( !controller_ ){
    controller_ = [[FeedMenuController alloc] initWithDelegate:self];
  } 
  return controller_;
}

@end
