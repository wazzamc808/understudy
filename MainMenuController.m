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

#import "HuluFeedController.h"
#import "NetflixFeedController.h"
#import "MainMenuController.h"
#import "ManageFeedsDialog.h"

#import <BackRow/BRControllerStack.h>
#import <BackRow/BRTextMenuItemLayer.h>
#import <BackRow/RUIPreferences.h>

@interface MainMenuController (PrivateMenuHandling)
- (void)_addFeed:(NSString*)feedURL withTitle:(NSString*)title;
- (void)_buildMenu;
@end

@implementation MainMenuController

- (id)init
{
  [super init];
  [self setListTitle:@"Understudy"];
  [[self list] setDatasource:self];
  items_ = [[NSMutableArray array] retain];
  controllers_ = [[NSMutableDictionary dictionary] retain];
  [self _buildMenu];
  return self;
}

- (void)dealloc
{
  [items_ release];
  [feeds_ release];
  [titles_ release];
  [controllers_ release];
  [super dealloc];
}

// we'll assume that FR won't try to release or copy the controller
static MainMenuController *sharedInstance_;
+ (MainMenuController*)sharedInstance
{
  if(!sharedInstance_) sharedInstance_ = [[MainMenuController alloc] init];
  return sharedInstance_;
}

void upgradePrefs(RUIPreferences* FRprefs)
{
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
}

- (void)_buildMenu
{  
  RUIPreferences* FRprefs = [RUIPreferences sharedFrontRowPreferences];
  upgradePrefs(FRprefs);
  NSDictionary* prefDict = (NSDictionary*) [FRprefs objectForKey:@"understudy"];
  feeds_ = [[[prefDict objectForKey:@"feeds"] mutableCopy] retain];
  titles_ = [[[prefDict objectForKey:@"titles"] mutableCopy] retain];
  for( NSString* title in titles_ ){
    BRTextMenuItemLayer* menuitem = [BRTextMenuItemLayer folderMenuItem];
    [menuitem setTitle:title];
    [items_ addObject:menuitem];
  }
  BRTextMenuItemLayer* manager = [BRTextMenuItemLayer menuItem];
  [manager setTitle:@"Manage Feeds"];
  [items_ addObject:manager];
  [controllers_ setObject:[[ManageFeedsDialog alloc] init] 
                   forKey:[manager title]];
  [[self list] addDividerAtIndex:[items_ count]-1 withLabel:nil];
  [[self list] reload];
}

// Takes the current feeds and pushed them in the FR preference storage. The
// feed's url is the key, and it's (user specified) title is the value.
- (void)savePreferences
{
  NSMutableDictionary* prefs = [NSMutableDictionary dictionary];
  [prefs setObject:titles_ forKey:@"titles"];
  [prefs setObject:feeds_ forKey:@"feeds"];
  RUIPreferences* FRprefs = [RUIPreferences sharedFrontRowPreferences];
  [FRprefs setObject:prefs forKey:@"understudy"];
}

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
  [[self list] removeDividers];
  BRTextMenuItemLayer* menuitem = [BRTextMenuItemLayer folderMenuItem];
  [menuitem setTitle:title];
  [items_ insertObject:menuitem atIndex:([items_ count]-1)];
  [feeds_ addObject:feedURL];
  [titles_ addObject:title];
  [[self list] addDividerAtIndex:[items_ count]-1 withLabel:nil];
  [[self list] reload];
  [self savePreferences];
}

- (void)removeFeedAtIndex:(long)index
{
  [[self list] removeDividers];
  [items_ removeObjectAtIndex:index];
  [feeds_ removeObjectAtIndex:index];
  [titles_ removeObjectAtIndex:index];
  [[self list] addDividerAtIndex:[items_ count]-1 withLabel:nil];
  [[self list] reload];
  [self savePreferences];
}

#pragma mark @protocol BEMenuListItemProvider
- (long)itemCount
{
  return [items_ count];
}

- (NSString*)titleForRow:(long)row
{
  return [(BRTextMenuItemLayer*)[self itemForRow:row] title];
}

- (BRLayer<BRMenuItemLayer>*)itemForRow:(long)row
{
  return [items_ objectAtIndex:row];
}

-(float)heightForRow:(long)row
{
  return 0; //0 tells FR to use its standard height
}

-(BOOL)rowSelectable:(long)row
{
  return YES;
}

#pragma mark Control Functionality

// return an appropriate feed controller depending on the url provided
BRController* controllerForURL(NSURL* url)
{
  NSString* host = [[url host] lowercaseString];
  NSRange range;

  range = [host rangeOfString:@"hulu"];
  if( range.location != NSNotFound )
    return [[HuluFeedController alloc] initWithUrl:url];
  
  range = [host rangeOfString:@"netflix"];
  if( range.location != NSNotFound )
    return [[NetflixFeedController alloc] initWithUrl:url];

  return nil;
}

- (void)itemSelected:(long)itemIndex
{
  NSString* title =  [self titleForRow:itemIndex];
  id con = [controllers_ objectForKey:title];
  if( !con ) {
    NSURL* url = [NSURL URLWithString:[feeds_ objectAtIndex:itemIndex]];
    con = controllerForURL(url);
    [controllers_ setObject:con forKey:title];
  }
  [[self stack] pushController:con];
}

@end
