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

#import "HuluFeed.h"
#import "NetflixFeed.h"
#import "YouTubeFeed.h"

#import "UNDPreferenceManager.h"
#import "UnderstudyAppliance.h"

#import <RUIPreferences.h>

#import <PubSub/PubSub.h>

#define DEFAULTS_DOMAIN @"com.apple.frontrow.appliance.understudy"

@implementation UNDPreferenceManager
@synthesize huluFSAlerted = huluFSAlerted_;
@synthesize alertsDisabled = alertsDisabled_;
@synthesize debugMode = debugMode_;

- (id)init
{
  [super init];
  subscribers_ = [[NSMutableSet alloc] init];
  self.huluFSAlerted = false;
  [self load];
  return self;
}

- (void)dealloc
{
  [feeds_ release];
  [titles_ release];
  [super dealloc];
}

static UNDPreferenceManager *sharedInstance_;
+ (UNDPreferenceManager*)sharedInstance
{
  if(!sharedInstance_)
    sharedInstance_ = [[UNDPreferenceManager alloc] init];
  return sharedInstance_;
}

- (long)feedCount
{
  return [titles_ count];
}

- (NSString*)titleAtIndex:(long)index
{
  if( index >= 0 && index < [titles_ count] )
    return [titles_ objectAtIndex:index];
  else
    return nil;
}

- (NSURL*)URLAtIndex:(long)index
{
  if( index >= 0 && index < [feeds_ count] )
  {
    NSString* feed = [feeds_ objectAtIndex:index];
    return [NSURL URLWithString:feed];
  } else {
    return nil;
  }
}

// preferred display for front row (if any) or main screen
+ (NSScreen*)screen
{
  RUIPreferences* prefs = [RUIPreferences sharedFrontRowPreferences];
  int prefdisplay  = [prefs integerForKey:@"FrontRowUsePreferredDisplayID"];
  if( prefdisplay ){
    for( NSScreen* screen in [NSScreen screens] ){
      NSDictionary* desc = [[[screen deviceDescription] retain] autorelease];
      if( [desc objectForKey:NSDeviceIsScreen] ){
        NSNumber* screenNum = [desc objectForKey:@"NSScreenNumber"];
        if( [screenNum intValue] == prefdisplay ) return screen;
      }
    }
  }
  return [NSScreen mainScreen];
}

+ (NSString*)accountForService:(NSString*)service
{
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  NSDictionary* prefDict = [defaults persistentDomainForName:DEFAULTS_DOMAIN];
  NSDictionary* accounts = [prefDict objectForKey:@"accounts"];
  return [accounts objectForKey:service];
}

+ (BOOL)alertsAreDisabled
{
  return  [[UNDPreferenceManager sharedInstance] alertsDisabled];
}

- (void)load
{
  RUIPreferences* FRprefs = [RUIPreferences sharedFrontRowPreferences];
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

  // versions up to 0.2 used "hulu" as the name for the feeds information
  NSDictionary* prefDict = (NSDictionary*) [FRprefs objectForKey:@"hulu"];
  if( prefDict )
  {
    prefDict = (NSDictionary*) [prefDict objectForKey:@"feeds"];
    // we now use an array of feeds, another array of titles
    NSMutableDictionary* newprefs = [NSMutableDictionary dictionary];
    NSArray* feeds = [prefDict allKeys];
    NSMutableArray* titles = [NSMutableArray array];
    for(NSString* url in feeds) [titles addObject:[prefDict objectForKey:url]];
    [newprefs setObject:titles forKey:@"titles"];
    [newprefs setObject:feeds forKey:@"feeds"];
    [FRprefs setObject:newprefs forKey:@"understudy"];
    [FRprefs setObject:nil forKey:@"hulu"];
  }

  // preferences moved from the FR plist into our own
  prefDict = (NSDictionary*) [FRprefs objectForKey:@"understudy"];
  if( prefDict ){
    [defaults setPersistentDomain:prefDict forName:DEFAULTS_DOMAIN];
    [FRprefs setObject:nil forKey:@"understudy"];
  }

  prefDict = [defaults persistentDomainForName:DEFAULTS_DOMAIN];

  feeds_ = [[[prefDict objectForKey:@"feeds"] mutableCopy] retain];
  if( !feeds_ ) feeds_ = [[NSMutableArray alloc] init];

  titles_ = [[[prefDict objectForKey:@"titles"] mutableCopy] retain];
  if( !titles_ ) titles_ = [[NSMutableArray alloc] init];

  alertsDisabled_ = ( [prefDict objectForKey:@"disableAlerts"] != nil);
  debugMode_ = ( [prefDict objectForKey:@"debugMode"] != nil);

  // ensure that all feeds are subscribed via PubSub
  PSClient* psClient = [PSClient applicationClient];
  for (NSString* urlString in feeds_) {
    NSURL* url = [NSURL URLWithString:urlString];
    PSFeed* feed = [psClient feedWithURL:url];
    if (!feed) [psClient addFeedWithURL:url];
  }
}

- (void)save
{
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  NSDictionary* prefDict = [defaults persistentDomainForName:DEFAULTS_DOMAIN];
  NSMutableDictionary* prefs;
  if( prefDict )
    prefs = [prefDict mutableCopy];
  else
    prefs = [NSMutableDictionary dictionary];
  [[prefs retain] autorelease];

  // the only preferences that are modifiable through the user interface are the
  // feeds and their titles, so only those need to be updated
  [prefs setObject:titles_ forKey:@"titles"];
  [prefs setObject:feeds_ forKey:@"feeds"];
  [defaults setPersistentDomain:prefs forName:DEFAULTS_DOMAIN];
}

#pragma mark Subscription
- (void)addSubscriber:(id<UNDPreferenceSubscriber>)subscriber
{
  [subscribers_ addObject:subscriber];
}

- (void)notifySubscribers
{
  id<UNDPreferenceSubscriber>subscriber;
  for( subscriber in subscribers_ )
    [subscriber preferencesDidChange];
}

#pragma mark Feed Arrangement
- (void)addFeed:(NSString*)feedURL withTitle:(NSString*)title
{
  // ensure no duplicate titles
  if( [titles_ containsObject:title] )
  {
    NSString* format = @"%@ %d", *newtitle;
    int i = 0;
    do{
      newtitle = [NSString stringWithFormat:format,title,i++];
    }while( [titles_ containsObject:newtitle]);
    title = newtitle;
  }

  [[PSClient applicationClient] addFeedWithURL:[NSURL URLWithString:feedURL]];

  [feeds_ addObject:feedURL];
  [titles_ addObject:title];
  [self save];
  [self notifySubscribers];
}

- (void)moveFeedFromIndex:(long)from toIndex:(long)to
{
  NSObject* item;
  // ensure the values are valid
  if( from < 0 || ([titles_ count]-1) < from
     || to < 0 || ([titles_ count]-1) < to
     || to == from ) return;

  // if the |to| position is after the |from|, the new index must be decremented
  // to acount for the item no longer being in the array by the time is't added
  if( from < to ) --to;

  // move the feed
  item = [[[feeds_ objectAtIndex:from] retain] autorelease];
  [feeds_ removeObjectAtIndex:from];
  [feeds_ insertObject:item atIndex:to];
  // move the title
  item = [[[titles_ objectAtIndex:from] retain] autorelease];
  [titles_ removeObjectAtIndex:from];
  [titles_ insertObject:item atIndex:to];
  [self save];
  [self notifySubscribers];
}

- (void)removeFeedAtIndex:(long)index
{
  NSString* url = [feeds_ objectAtIndex:index];
  PSClient* client = [PSClient applicationClient];
  PSFeed* feed = [client feedWithURL:[NSURL URLWithString:url]];
  if (feed) [client removeFeed:feed];

  [feeds_ removeObjectAtIndex:index];
  [titles_ removeObjectAtIndex:index];
  [self save];
  [self notifySubscribers];
}

- (void)renameFeedAtIndex:(long)index withTitle:(NSString*)title
{
  [titles_ replaceObjectAtIndex:index withObject:[[title copy]autorelease]];
  [self save];
  [self notifySubscribers];
}

@end
