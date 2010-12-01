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

#import "AddFeedDialog.h"
#import "MainMenuController.h"

#import <BRAlertController.h>
#import <BRControllerStack.h>

#import <AppKit/NSPasteboard.h>

@implementation AddFeedDialog

- (id)init
{
  [super init];
  [self setTitle:@"Add Feed"];
  [self addOptionText:@"Hulu"];
  [self addOptionText:@"Netflix"];
  [self addOptionText:@"YouTube"];
  [self addOptionText:@"The Daily Show"];
  [self addOptionText:@"URL in Clipboard"];
  [self setActionSelector:@selector(itemSelected) target:self];  
  return self;
}

- (void)dealloc
{
  [hulu_ release];
  [netflix_ release];
  [dailyshow_ release];
  [super dealloc];
}

- (BOOL)_validateFeed:(NSURL*)feed
{
  NSError* err;
  NSXMLDocument* doc;
  
  doc = [[[NSXMLDocument alloc] initWithContentsOfURL:feed
                                             options:0
                                                error:&err] autorelease];
  if( !doc || err ) return NO;
  return YES;
}

// show an error indicating that the clipboard doesn't seem to have a url
- (void)_presentInvalidURLAlert
{
  BRController* alert;
  alert = [[BRAlertController alertOfType:3
                                   titled:@"Error" 
                              primaryText:@"Not a URL"
                            secondaryText:@"The clipboard contents do not app"\
            "ear to be a valid URL."] retain];
  [[self stack] swapController:[alert autorelease]];
}

- (void)_presentInvalidHostAlert
{
  BRController* alert;
  alert = [[BRAlertController alertOfType:3 //kBRAlertTypeError
                                   titled:@"Error" 
                              primaryText:@"Invalid Host"
                            secondaryText:@"The URL stored on the clipboard d"\
            "oes not refer to a supported video provider."] retain];
  [[self stack] swapController:[alert autorelease]];
}

- (void)_presentInvalidFeedAlert
{
  BRController* alert;
  alert = [[BRAlertController alertOfType:3
                                   titled:@"Error"
                              primaryText:@"Invalid Feed"
                            secondaryText:@"The URL does not appear to refer t"\
            "o a valid feed."] retain];
  [[self stack] swapController:[alert autorelease]];
}

// looks for a string in the clipboard. if there isn't a string, or it isn't
// a url, or that url doesn't refer to a known video provider, sound an error
- (void)_loadFeedFromPasteboard
{
  NSPasteboard* pasteboard = [NSPasteboard generalPasteboard];
  NSString* copied = [pasteboard stringForType:@"NSStringPboardType"];
  // NSURL expects a full feed including protocol, but doesn't accept some of
  // the protocols (like feed:// which safari likes)
  if( [copied hasPrefix:@"feed://"] )
    copied = [copied stringByReplacingOccurrencesOfString:@"feed://"
                                               withString:@"http://"];

  NSURL* url = [NSURL URLWithString:copied];
  NSString* host = [[url host] lowercaseString];
  if( !host )
    [self _presentInvalidURLAlert];

  else if( ![self _validateFeed:url] )
    [self _presentInvalidHostAlert];
  
  else if( [host rangeOfString:@"hulu"].location != NSNotFound )
  {
    [[UNDPreferenceManager sharedInstance] addFeed:[url absoluteString] 
                                         withTitle:@"Hulu Feed"];
    [[self stack] popToController:[MainMenuController sharedInstance]];
  }
  
  else if( [host rangeOfString:@"netflix"].location != NSNotFound )
  {
    [[UNDPreferenceManager sharedInstance] addFeed:[url absoluteString] 
                                         withTitle:@"Netflix Feed"];
    [[self stack] popToController:[MainMenuController sharedInstance]];
  }
  
  else if( [host rangeOfString:@"gdata.youtube"].location != NSNotFound )
  {
    [[UNDPreferenceManager sharedInstance] addFeed:[url absoluteString]
                                         withTitle:@"YouTube Feed"];
    [[self stack] popToController:[MainMenuController sharedInstance]];    
  }
  
  else if( [host rangeOfString:@"bbc"].location != NSNotFound )
  {
    [[UNDPreferenceManager sharedInstance] addFeed:[url absoluteString]
                                         withTitle:@"BBC Feed"];
    [[self stack] popToController:[MainMenuController sharedInstance]];    
  }
  
  else if( [host rangeOfString:@"dailyshow"].location != NSNotFound )
  {
    [[UNDPreferenceManager sharedInstance] addFeed:[url absoluteString]
                                         withTitle:@"The DailyShow Feed"];
    [[self stack] popToController:[MainMenuController sharedInstance]];    
  }
    
  else
    [self _presentInvalidHostAlert];
}

// call-back for an item having been selected
- (void)itemSelected
{
  switch([self selectedIndex])
  {
    case 0: // hulu
      if( !hulu_ ) hulu_ = [[HuluAddDialog alloc] init];
      [[self stack] pushController:hulu_];
      break;
    case 1: // netflix
      if( !netflix_ ) netflix_ = [[NetflixAddDialog alloc] init];
      [[self stack] pushController:netflix_];
      break;
    case 2: // YouTube
      if( !youtube_ ) youtube_ = [[UNDYouTubeAddDialog alloc] init];
      [[self stack] pushController:youtube_];
      break;
    case 3: // DailyShow
      if( !dailyshow_ ) dailyshow_ = [[DailyShowAddDialog alloc] init];
      [[self stack] pushController:dailyshow_];
      break;
    case 4: // pasteboard
      [self _loadFeedFromPasteboard];
      break;
    default:
      NSLog(@"unexpected index in add dialog");
  }
}

@end
