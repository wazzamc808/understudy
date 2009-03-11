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

#import "UNDiPlayerAsset.h"
#import "UNDiPlayerController.h"
#import "UNDNSXMLElement+Parsing.h"

#import <BRImage.h>
#import <BRImageManager.h>
#import <BRTextMenuItemLayer.h>

@implementation UNDiPlayerAsset

- (id)initWithXMLElement:(NSXMLElement*)dom
{
  [super init];
  imageManager_ = [BRImageManager sharedInstance];
  title_ = [[[dom firstElementNamed:@"title"] stringValue] retain];
  
  NSXMLElement* alternate = [[dom linkWithRelationship:@"alternate"] retain];
  NSString*  href = [[alternate attributeForName:@"href"] stringValue];
  url_ = [[NSURL URLWithString:href] retain];
  
  NSXMLElement* element = [alternate firstElementNamed:@"media:content"];
  element = [element firstElementNamed:@"media:thumbnail"];
  href = [[element attributeForName:@"url"] stringValue];
  NSURL* thumburl = [NSURL URLWithString:href];
  thumbnailID_ = [[imageManager_ writeImageFromURL:thumburl] retain];
  return self;
}

- (void)dealloc
{
  [menuitem_ release];
  [thumbnailID_ release];
  [title_ release];
  [url_ release];
  [super dealloc];
}

- (NSString*)title{ return title_; }
- (NSURL*)url{ return url_; }
- (BRImage*)coverArt{ return [imageManager_ imageNamed:thumbnailID_]; }

- (BRController*)controller
{ 
  BRController* con = [[UNDiPlayerController alloc] initWithAsset:self];
  return [con autorelease];
}

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

@end
