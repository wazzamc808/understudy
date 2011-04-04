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

#import "UNDiPlayerAddDialog.h"
#import "UNDiPlayerAssetProvider.h"
#import "UNDMutableCollection.h"

#import <BRControllerStack.h>
#import <BRListControl.h>
#import <BRTextMenuItemLayer.h>

#import <PubSub/PubSub.h>

@implementation UNDiPlayerAddDialog

/* feeds.bbc.co.uk/iplayer/categories/childrens/list
Children's, Comedy, Drama, Entertainment, Factual, Films, Learning, Music
News, Religion & Ethics, Sport, Sign Zone, Northern Ireland, Scotland, Wales */

- (id)init
{
  [super init];
  [self setTitle:@"BBC Feeds"];
  feeds_ = [[NSMutableArray arrayWithObjects:@"http://feeds.bbc.co.uk/iplayer/bbc_one/list"
             @"http://feeds.bbc.co.uk/iplayer/bbc_two/list",
             @"http://feeds.bbc.co.uk/iplayer/bbc_three/list",
             @"http://feeds.bbc.co.uk/iplayer/bbc_four/list",
             @"http://feeds.bbc.co.uk/iplayer/cbbc/list",
             @"http://feeds.bbc.co.uk/iplayer/cbeebies/list",
             @"http://feeds.bbc.co.uk/iplayer/bbc_news24/list",
             @"http://feeds.bbc.co.uk/iplayer/bbc_parliament/list",
             @"http://feeds.bbc.co.uk/iplayer/bbc_alba/list",
             nil] retain];
  titles_ = [[NSMutableArray arrayWithObjects: @"BBC 1",
              @"BBC 2",
              @"BBC 3",
              @"BBC 4",
              @"CBBC",
              @"CBeebies",
              @"BBC News",
              @"Parliament",
              @"BBC Alba", nil] retain];
  [[self list] setDatasource:self];
  return self;
}

- (void)dealloc
{
  [titles_ release];
  [feeds_ release];
  [super dealloc];
}

- (void)setCollection:(UNDMutableCollection*)collection
{
  collection_ = collection;
}

// call-back for an item having been selected
- (void)itemSelected:(long)index
{
  if (index < [feeds_ count]) {
    NSString* feed = [feeds_ objectAtIndex:index];
    NSString* title = [titles_ objectAtIndex:index];
    NSDictionary* asset =
      [NSDictionary dictionaryWithObjectsAndKeys:feed, @"URL", title, @"title",
                    UNDiPlayerAssetProviderId, @"provider", nil];
    [collection_ addAssetWithDescription:asset
                                 atIndex:LONG_MAX];
    [[PSClient applicationClient] addFeedWithURL:[NSURL URLWithString:feed]];
  }
  [[self stack] popController];
}

# pragma mark BRMenuListItemProvider

- (long)itemCount{ return [feeds_ count]; }
- (float)heightForRow:(long)row
{
  (void)row;
  return 0;
}

- (BOOL)rowSelectable:(long)row
{
  (void)row;
  return YES;
}

- (id)titleForRow:(long)row{ return [titles_ objectAtIndex:row]; }

- (id)itemForRow:(long)row
{
  BRTextMenuItemLayer* item;
  item = [BRTextMenuItemLayer menuItem];
  [item setTitle:[self titleForRow:row]];
  return item;
}

@end
