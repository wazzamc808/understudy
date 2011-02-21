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

#import <BRTextMenuItemLayer.h>

@implementation UNDiPlayerFeed
- (id)initWithTitle:(NSString*)title forUrl:(NSURL*)url
{
  [super initWithTitle:title];
  url_ = [url retain];
  return self;
}

- (void)dealloc
{
  [url_ release];
  [super dealloc];
}

- (NSArray*)currentAssets
{
  NSMutableArray* assets = [[[NSMutableArray alloc] init] autorelease];
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

- (BRController*)controller
{
  if( !controller_ )
    controller_ = [[UNDMenuController alloc] initWithDelegate:self];
  return controller_;
}

- (BRControl*)preview
{
  return nil;
}

@end
