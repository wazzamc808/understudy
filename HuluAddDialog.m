//
//  Copyright 2008 Kirk Kelsey.
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

#import "HuluAddDialog.h"
#import "MainMenuController.h"

#import <BackRow/BRControllerStack.h>

@implementation HuluAddDialog

#define FEED_OPTION_COUNT 8

NSString* HULUURLS[] = {
@"http://www.hulu.com/feed/recent/videos", 
@"http://www.hulu.com/feed/recent/shows",
@"http://www.hulu.com/feed/recent/movies",
@"http://www.hulu.com/feed/highest_rated/videos",
@"http://www.hulu.com/feed/popular/videos/today",
@"http://www.hulu.com/feed/popular/videos/this_week",
@"http://www.hulu.com/feed/popular/videos/this_month",
@"http://www.hulu.com/feed/popular/videos/all_time"};

NSString* HULUTITLES[] ={
@"Recently Added Videos",
@"Recently Added Shows",
@"Recently Added Movies",
@"Highest Rated Videos",
@"Most Popular Videos Today",
@"Most Popular Videos This Week",
@"Most Popular Videos This Month",
@"Most Popular Videos All Time"};

- (id)init
{
  [super init];
  [self setTitle:@"Hulu Feeds"];
  int i = 0;
  for( i=0; i < FEED_OPTION_COUNT; i++ ) [self addOptionText:HULUTITLES[i]];
  [self setActionSelector:@selector(itemSelected) target:self];
  return self;
}

- (void)dealloc
{
  [super dealloc];
}

// call-back for an item having been selected
- (void)itemSelected
{  
  int index = [self selectedIndex];
  if( index < FEED_OPTION_COUNT ){
    MainMenuController* main_ = [MainMenuController sharedInstance];
    [main_ addFeed:HULUURLS[index] withTitle:HULUTITLES[index]];
  }
  [[self stack] popController];
}

@end
