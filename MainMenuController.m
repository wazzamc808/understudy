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

#import "FeedMenuController.h"
#import "MainMenuController.h"

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
  controllers_ = [[NSMutableDictionary dictionary] retain];
  [self _buildMenu];
  return self;
}

- (void)dealloc
{
  [items_ release];
  [feeds_ release];
  [addController_ release];
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

- (void)_buildMenu
{
  items_ = [[NSMutableArray array] retain];
  feeds_ = [[NSMutableArray array] retain];

  BRTextMenuItemLayer* add = [BRTextMenuItemLayer menuItem];
  [add setTitle:@"Add Feed"];
  [items_ addObject:add];  
  
  RUIPreferences* FRprefs = [RUIPreferences sharedFrontRowPreferences];
  NSDictionary* prefDict = (NSDictionary*) [FRprefs objectForKey:@"hulu"];
  NSDictionary* feeds = [prefDict objectForKey:@"feeds"];
  NSArray* feedURLs = [feeds allKeys];
  for( NSString* url in feedURLs ){
    NSString* title = [feeds objectForKey:url];
    [self _addFeed:url withTitle:title];
  }
  [[self list] reload];
}

// Takes the current feeds and pushed them in the FR preference storage. The
// feed's url is the key, and it's (user specified) title is the value.
- (void)_savePreferences
{
  NSMutableArray* titles = [NSMutableArray array];
  int i;
  for(i = 0; i < [feeds_ count]; i++){
    BRTextMenuItemLayer* menuitem = [items_ objectAtIndex:i];
    [titles addObject:[menuitem title]];
  }
  NSDictionary* subscriptions = [NSDictionary dictionaryWithObjects:titles
                                                            forKeys:feeds_];
  NSDictionary* huluPrefs = [NSDictionary dictionaryWithObject:subscriptions
                                                        forKey:@"feeds"];
  RUIPreferences* FRprefs = [RUIPreferences sharedFrontRowPreferences];
  [FRprefs setObject:huluPrefs forKey:@"hulu"];
}

#pragma mark Adding Feeds
// Display a controller allowing the user to add a new feed.
- (void)_presentAddDialog
{
  if( !addController_ )
  {
    addController_ = [[BRTextEntryController alloc] retain];
    [addController_ initWithTextEntryStyle:0];
  }
  [addController_ reset];
  [addController_ setTitle:@"Add Feed"];
  [addController_ setTextEntryTextFieldLabel:@"hulu.com/feed/"];
  [addController_ setPromptText:@"Enter the url of a Hulu feed"];
  [addController_ setTextEntryCompleteDelegate:self];
  newfeed_ = nil;
  [[self stack] pushController:addController_];
}

// After calling this method, the modal will have a new feed. The display
// update must be invoked explicitly.
- (void)_addFeed:(NSString*)feedURL withTitle:(NSString*)title
{
  [[self list] removeDividers];
  if( [feeds_ count] == 0)
  {
    BRTextMenuItemLayer* del= [BRTextMenuItemLayer menuItem];
    [del setTitle:@"Remove Feed"];
    [items_ addObject:del];
  }  
  BRTextMenuItemLayer* menuitem = [BRTextMenuItemLayer folderMenuItem];
  [menuitem setTitle:title];
  [items_ insertObject:menuitem atIndex:0];
  [feeds_ insertObject:feedURL atIndex:0];
  [[self list] addDividerAtIndex:[items_ count]-2 withLabel:nil];
}

// <BRTextEntryDelegate> methods
- (void)textDidChange:(id<BRTextContainer>)container
{ }

- (void)textDidEndEditing:(id<BRTextContainer>)container
{
  if( !newfeed_ ){
    newfeed_ = [[container stringValue] retain];
    [addController_ reset];
    [addController_ setPromptText:@"Name the feed"];
    [addController_ setTextEntryTextFieldLabel:@""];
  }else{
    NSString* feed = [NSString stringWithString:@"http://www.hulu.com/feed/"];
    feed = [feed stringByAppendingString:newfeed_];
    NSString* title = [container stringValue];
    if( [title length] == 0 ) title = [feed lastPathComponent];
    [self _addFeed:feed withTitle:title];
    [self _savePreferences];
    [[self list] reload];
    [[self stack] popController];
  }
}

#pragma mark Removing Feeds
// Display a controller allowing the user to remove a new feed.
- (void)_presentRemoveDialog
{
  if( [feeds_ count] == 0) return;
  [removeDialog_ release];
  removeDialog_ = [[BROptionDialog alloc] init];
  [removeDialog_ setTitle:@"Remove Feed"];
  
  // because of the "Add" and "Remove", we'll iterate of the length of the 
  // |feeds_| array, but the text to present to the user comes from the item.
  int i;
  for(i = 0; i<[feeds_ count]; i++)
  {
    BRTextMenuItemLayer* menuitem = (BRTextMenuItemLayer*) [self itemForRow:i];
    [removeDialog_ addOptionText:[menuitem title]];
  }
  [removeDialog_ setActionSelector:@selector(_removeCallBack) target:self];
  [[self stack] pushController:removeDialog_];
}

// call back for the remove dialog
- (void) _removeCallBack
{
  long index = [removeDialog_ selectedIndex];
  [items_ removeObjectAtIndex:index];
  [feeds_ removeObjectAtIndex:index];
  [controllers_ removeObjectForKey:[removeDialog_ selectedText]];
  [[self list] removeDividers];
  // if only the "Add" and "Remove" items remain, lose the "Remove"
  if( [items_ count] == 2 ) [items_ removeLastObject];
  else [[self list] addDividerAtIndex:[items_ count]-2 withLabel:nil];
  [[self list] reload];
  [self _savePreferences];
  [[self stack] popController];
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

// When the menu is loaded from its parent, we don't need to do anything special
// but when we return from a submenu, we want to make sure it's spinner is off
- (void)controlWillActivate
{
  BRTextMenuItemLayer* item;
  item = (BRTextMenuItemLayer*) [self itemForRow:[self selectedItem]];
  [item setWaitSpinnerActive:NO];
}

- (void)itemSelected:(long)itemIndex
{
  BRTextMenuItemLayer* item;
  int count = [items_ count];
  if( itemIndex > count || count == 0 ) return;
  else if( count == 1 || itemIndex == count - 2 ) [self _presentAddDialog];
  else if( itemIndex == count-1) [self _presentRemoveDialog];
  else {
    item = (BRTextMenuItemLayer*) [self itemForRow:itemIndex];
    [item setWaitSpinnerActive:YES];
    NSString* title = [item title];
    id con = [controllers_ valueForKey:title];
    if( con ) [[self stack] pushController:con];
    else {
      NSURL* url = [NSURL URLWithString:[feeds_ objectAtIndex:itemIndex]];
      con = [[FeedMenuController alloc] initWithUrl:url];
      [controllers_ setObject:con forKey:title];
      [[self stack] pushController:con];
    }
  }
}

@end
