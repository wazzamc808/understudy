//
//  DailyShowAddDialog.m
//  understudy
//
//  Created by jb on 11/5/10.
//  Copyright 2010 Jason Brown. All rights reserved.
//

#import "DailyShowAddDialog.h"
#import <MainMenuController.h>

#import <BRControllerStack.h>
#import <BRListControl.h>
#import <BRTextMenuItemLayer.h>

@implementation DailyShowAddDialog

- (id)init
{
  [super init];
  [self setTitle:@"The DailyShow Feeds"];
  feeds_ = [[NSMutableArray arrayWithObjects:@"http://www.thedailyshow.com/full-episodes", nil] retain];
  titles_ = [[NSMutableArray arrayWithObjects: @"Daily Show - Full Episodes", nil] retain];
  [[self list] setDatasource:self];
  return self;
}

- (void)dealloc
{
  [titles_ release];
  [feeds_ release];
  [super dealloc];
}

// call-back for an item having been selected
- (void)itemSelected:(long)index
{  
  if( index < [feeds_ count] ){
    UNDPreferenceManager* pref = [UNDPreferenceManager sharedInstance];
    [pref addFeed:[feeds_ objectAtIndex:index] 
        withTitle:[titles_ objectAtIndex:index]];
  }
  [[self stack] popController];
}

# pragma mark BRMenuListItemProvider

- (long)itemCount{ return [feeds_ count]; }
- (float)heightForRow:(long)row{ return 0; }
- (BOOL)rowSelectable:(long)row{ return YES; }
- (id)titleForRow:(long)row{ return [titles_ objectAtIndex:row]; }

- (id)itemForRow:(long)row
{
  BRTextMenuItemLayer* item;
  item = [BRTextMenuItemLayer menuItem];
  [item setTitle:[self titleForRow:row]];
  return item;
}

@end
