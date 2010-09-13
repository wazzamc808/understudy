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

#import "NetflixFeed.h"
#import "NetflixController.h"

#import <BRControllerStack.h>
#import <BRComboMenuItemLayer.h>
#import <BRTextMenuItemLayer.h>

#import <Foundation/NSXMLDocument.h>
#import <PubSub/PubSub.h>

@interface NetflixFeed (Private)
- (void)loadAssets:(NSArray*)feedItems;
- (void)startNextUpdate;
@end

@implementation NetflixFeed

- (id)initWithTitle:(NSString*)title forUrl:(NSURL*)url
{
  [super init];
  title_ = [title copy];
  url_ = [url retain];
  return self;
}

- (void)dealloc
{
  [title_ release];
  [url_ release];
  [super dealloc];
}

- (NSArray*)currentAssets
{
  NSMutableArray* assets = [NSMutableArray array];
  NSError* err;
  NSXMLDocument* doc;
  doc = [[[NSXMLDocument alloc] initWithContentsOfURL:url_
                                              options:0
                                                error:&err] autorelease];
  if( !doc ) return nil;
  NSXMLElement* root = [doc rootElement];
  NSXMLElement* channel = [[root elementsForName:@"channel"] objectAtIndex:0];
  NSArray* feeditems = [channel elementsForName:@"item"];
  assets_ = assets;
  [self loadAssets:feeditems];
  return assets;
}

- (void)loadAssets:(NSArray*)feedItems
{
  // Load the first few assets, refresh the list, then put the remaining assets
  // on a queue to be completely loaded lazily.
  for (NSXMLElement* feedItem in feedItems) {
    NetflixAsset* asset = [[NetflixAsset alloc] initWithXMLElement:feedItem];
    [assets_ addObject:asset];
    [asset setDelegate:self];
  }

  // start a small number of asset discovery tasks
  unfinishedAssets_ = [assets_ mutableCopy];
  int i;
  for (i = 0; i < 5; ++i) [self assetUpdated:nil];
}

- (NSString*)title{ return title_; }
- (BRLayer<BRMenuItemLayer>*)menuItem
{
  BRTextMenuItemLayer*item = [BRTextMenuItemLayer folderMenuItem];
  [item setTitle:[self title]];
  return item;
}

- (BRController*)controller
{
  if (!controller_)
    controller_ = [[FeedMenuController alloc] initWithDelegate:self];
  return controller_;
}

- (void)assetUpdated:(NetflixAsset*)asset
{
  // the asset may be nil (to simply force another update)
  @synchronized(unfinishedAssets_) {
    ++updateSlots_;
    ++finishedAssets_;
    [self startNextUpdate];
  }
}

- (void)startNextUpdate
{
  @synchronized(unfinishedAssets_) {
    // Because the first few assets are explicitly started on auto discovery,
    // they may all finish before the second batch is built. In that case, we
    // need to start additional asset discovery processes.
    while (updateSlots_ && [unfinishedAssets_ count]) {
      --updateSlots_;
      NetflixAsset* asset = [unfinishedAssets_ objectAtIndex:0];
      [unfinishedAssets_ removeObjectAtIndex:0];
      [asset startAutoDiscovery];
    }
  }
}

@end
