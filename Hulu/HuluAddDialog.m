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

- (id)init
{
  [super init];
  [self setTitle:@"Hulu Feeds"];
  feeds_ = [[NSMutableArray arrayWithObjects: 
             @"http://hulu.com/feed/recent/videos", 
             @"http://hulu.com/feed/recent/shows", 
             @"http://hulu.com/feed/recent/movies", 
             @"http://hulu.com/feed/highest_rated/videos", 
             @"http://hulu.com/feed/popular/videos/today", 
             @"http://hulu.com/feed/popular/videos/this_week", 
             @"http://hulu.com/feed/popular/videos/this_month", 
             @"http://hulu.com/feed/popular/videos/all_time", nil] retain];
  titles_ = [[NSMutableArray arrayWithObjects: @"Recently Added Videos", 
              @"Recently Added Shows", @"Recently Added Movies", 
              @"Highest Rated Videos", @"Most Popular: Today", 
              @"Most Popular: This Week", @"Most Popular: This Month", 
              @"Most Popular: All Time", nil] retain];
  for( NSString* title in titles_ ) [self addOptionText:title];
  [self startAutoDiscovery];
  [self setActionSelector:@selector(itemSelected) target:self];
  return self;
}

- (void)dealloc
{
  [titles_ release];
  [feeds_ release];
  [profile_ release];
  [super dealloc];
}

// call-back for an item having been selected
- (void)itemSelected
{  
  int index = [self selectedIndex];
  if( index < [feeds_ count] ){
    MainMenuController* main_ = [MainMenuController sharedInstance];
    [main_ addFeed:[feeds_ objectAtIndex:index] 
         withTitle:[titles_ objectAtIndex:index]];
  }
  [[self stack] popController];
}

// once Hulu parses show feeds
// www.hulu.com/feed/show_recommendations/<id>
// www.hulu.com/feed/subscriptions/<id>
# pragma mark Auto Discovery

- (void)startAutoDiscovery
{
  NSURL* url = [NSURL URLWithString:@"http://www.hulu.com/users/profile"];
  NSURLRequest* request = [NSURLRequest requestWithURL:url];
  if( ![[NSURLConnection alloc] initWithRequest:request
                                       delegate:self
                               startImmediately:YES] )
    NSLog(@"Failed to open connection for Hulu feed auto-discovery");
}

- (void)_autoDiscover
{
  [feeds_ addObject:[@"www.hulu.com/feed/queue/" stringByAppendingString:profile_]];
  [titles_ addObject:@"Hulu Queue"];
  [self addOptionText:@"Hulu Queue"];
  [feeds_ addObject:[@"www.hulu.com/feed/recommendations/" stringByAppendingString:profile_]];
  [titles_ addObject:@"Hulu Recommended Videos"];
  [self addOptionText:@"Hulu Recommended Videos"];
}

# pragma mark NSURLConnection Delegation

- (void)connection:(NSURLConnection*)connection 
didReceiveResponse:(NSURLResponse*)response
{
  // a resonse with URL starting with www.hulu.com/users/profile means success
  NSString* path = [[response URL] path];
  if( [path hasPrefix:@"/users/profile"] )
  {
    profile_ = [[path lastPathComponent] retain];
    [connection cancel];
    [self _autoDiscover];
  }
}

- (void)connection:(NSURLConnection*)connection 
  didFailWithError:(NSError*)error
{
  [connection release];
}

- (void)connectionDidFinishLoading:(NSURLConnection*)connection
{
  [connection release];
}

@end
