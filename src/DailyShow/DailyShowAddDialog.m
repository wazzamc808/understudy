//  Copyright 2011 Jason Brown.
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

#import "DailyShowAddDialog.h"

#import <BRControllerStack.h>
#import <BRListControl.h>
#import <BRTextMenuItemLayer.h>

#import "UNDDailyShowAssetProvider.h"

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

- (void)setCollection:(UNDMutableCollection*)collection
{
  collection_ = collection;
}

// call-back for an item having been selected
- (void)itemSelected:(long)index
{
  if (index < [feeds_ count]) {
    NSString* title = [titles_ objectAtIndex:index];
    NSString* url = [feeds_ objectAtIndex:index];
    NSDictionary* asset =
      [NSDictionary dictionaryWithObjectsAndKeys:url, UNDAssetProviderUrlKey,
                    title, UNDAssetProviderTitleKey,
                    UNDDailyShowAssetProviderId, UNDAssetProviderNameKey, nil];
    [collection_ addAssetWithDescription:asset
                                 atIndex:LONG_MAX];
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
