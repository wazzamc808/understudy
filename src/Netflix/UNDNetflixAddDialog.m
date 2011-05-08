//
//  Copyright 2008-2011 Kirk Kelsey.
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

#import "Netflix/UNDNetflixAddDialog.h"

#import <AppKit/NSPasteboard.h>
#import <PubSub/PubSub.h>

#import <BRHeaders/BRControllerStack.h>

#import "Base/UNDMutableCollection.h"
#import "Netflix/UNDNetflixAssetProvider.h"

@interface UNDNetflixAddDialog (PrivateMethods)
- (void)_startAutoDiscovery;
@end

@implementation UNDNetflixAddDialog

typedef enum {
  kNewWatchInstantly,
  kPasteboardUrl,
  kMyQueue                      // (Keep this last)
} NetflixAssetOption;

static const NSString* kNewWatchInstantlyUrl
= @"http://netflix.com/NewWatchInstantlyRSS";

NSString* NETFLIXTITLES[] = {
  @"New Choices to Watch Instantly",
  @"Queue URL from clipboard",
  @"My Netflix Queue"
};

- (id)init
{
  [super init];
  [self setTitle:@"Netflix Feeds"];
  int i = 0;
  for (i=0; i < kMyQueue; i++)
    [self addOptionText:NETFLIXTITLES[i]];
  [self setActionSelector:@selector(itemSelected) target:self];
  // start the autodiscovery process
  [self _startAutoDiscovery];
  return self;
}

- (void)dealloc
{
  [super dealloc];
  [connection_ release];
  [pageData_ release];
  [queue_ release];
}

- (void)setCollection:(UNDMutableCollection*)collection
{
  collection_ = collection;
}

// call-back for an item having been selected
- (void)itemSelected
{
  int index = [self selectedIndex];

  NSString *url = nil, *title = NETFLIXTITLES[index];

  switch (index) {
  case kNewWatchInstantly:
    url = [[kNewWatchInstantlyUrl copy] autorelease];
    break;
  case kPasteboardUrl:
    url = [[NSPasteboard generalPasteboard]
                        stringForType:@"NSStringPboardType"];
    break;
  case kMyQueue:
    url = queue_;
    break;
  }

  if (url && title) {
    NSDictionary* asset =
      [NSDictionary dictionaryWithObjectsAndKeys:url, @"URL", title, @"title",
                    UNDNetflixAssetProviderId, @"provider", nil];
    [collection_ addAssetWithDescription:asset
                                 atIndex:LONG_MAX];
    [[PSClient applicationClient] addFeedWithURL:[NSURL URLWithString:url]];
  }

  [[self stack] popController];
}

# pragma mark Auto Discovery

// load the web page http://www.netflix.com/RSSFeeds and look for a link to the
// users watch instantly queue. This requires that they be logged in through
// Safari
- (void)_startAutoDiscovery
{
  NSURL* url = [NSURL URLWithString:@"http://www.netflix.com/RSSFeeds"];
  NSURLRequest* request = [NSURLRequest requestWithURL:url];
  connection_ = [[NSURLConnection alloc] initWithRequest:request
                                                delegate:self
                                        startImmediately:YES];
  if(connection_) pageData_ = [[NSMutableData data] retain];
  else NSLog(@"Failed to open connection for Netflix feed auto-discovery");
}

- (void)_autoDiscover
{
  NSStringEncoding encoding = NSISOLatin1StringEncoding;
  NSRange start, end, searchRange, queueRange;

  // Convert the URL contents to a string.
  NSString* contents = [[[NSString alloc] initWithData:pageData_
                                              encoding:encoding] autorelease];
  // Identify the beginning of the URL for "My" queue.
  start = [contents rangeOfString:@"http://rss.netflix.com/QueueEDRSS?id="];
  if (start.location == NSNotFound) return;

  // Construct a range covering everything after the |start| identifier up to
  // the end of the |contents| string. The length is 1> the valid position.
  searchRange = NSMakeRange(NSMaxRange(start),
                            [contents length] - NSMaxRange(start) - 1);

  assert (NSMaxRange(searchRange) <= [contents length]);

  // Find the matching quote that ends the URL.
  end = [contents rangeOfString:@"\"" options:0 range:searchRange];

  if (end.location == NSNotFound) return;

  // Add a new option for the discovered queue.
  queueRange = NSMakeRange(start.location, end.location-start.location);
  if ((queueRange.location + queueRange.length) <= [contents length])
  {
    queue_ = [[contents substringWithRange:queueRange] retain];
    [self addOptionText:@"My Watch Instantly Queue"];
  }
}

# pragma mark NSURLConnection Delegation

- (void)connection:(NSURLConnection*)connection
didReceiveResponse:(NSURLResponse*)response
{
  (void)connection;
  (void)response;
  [pageData_ setLength:0];
}

- (void)connection:(NSURLConnection*)connection
  didFailWithError:(NSError*)error
{
  NSLog(@"Netflix RSS auto-discovery failed: %@",error);
  [pageData_ release];
  [connection release];
  pageData_ = nil;
}

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData *)data
{
  (void)connection;
  [pageData_ appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection*)connection
{
  [connection release];
  [self _autoDiscover];
}

@end
