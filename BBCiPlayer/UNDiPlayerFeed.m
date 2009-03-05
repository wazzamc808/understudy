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

#import "UNDiPlayerFeed.h"
#import "UNDiPlayerAsset.h"

#import <BackRow/BRTextMenuItemLayer.h>

@implementation UNDiPlayerFeed
- (id)initWithTitle:(NSString*)title forUrl:(NSURL*)url
{
  [super init];
  url_ = [url retain];
  title_ = [title copy];
  return self;
}

- (void)dealloc
{
  [item_ release];
  [title_ release];
  [url_ release];
  [super dealloc];
}

- (NSString*)title
{
  return title_;
}

- (NSArray*)currentAssets
{
  NSMutableArray* assets = [[NSMutableArray alloc] init];
  NSError* err;
  NSXMLDocument* doc = [NSXMLDocument alloc];
  doc = [[doc initWithContentsOfURL:url_ 
                            options:0
                              error:&err] autorelease];
  if( !doc ) return nil;
  NSXMLElement* root = [doc rootElement];
  for( NSXMLElement* feeditem in [root elementsForName:@"entry"] ){
    UNDiPlayerAsset* asset;
    asset = [[[UNDiPlayerAsset alloc] initWithXMLElement:feeditem] autorelease];
    [assets insertObject:asset atIndex:0];
  }
  return assets;
}

- (BRLayer<BRMenuItemLayer>*)menuItem
{
  if( !item_ ){
    item_ = [[BRTextMenuItemLayer folderMenuItem] retain];
    [item_ setTitle:title_];
  }
  return item_;
}

- (BRController*)controller
{
  if( !controller_ )
    controller_ = [[FeedMenuController alloc] initWithDelegate:self];
  return controller_;
}

- (BRControl*)preview
{
  return nil;
}

@end
