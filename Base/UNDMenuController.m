//
//  Copyright 2009-2010 Kirk Kelsey.
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

#import "UNDEditDialog.h"
#import "UNDManageDialog.h"
#import "UNDMenuController.h"
#import "BaseController.h"
#import "UnderstudyAsset.h"
#import "BaseUnderstudyAsset.h"
#import "UNDLoadingAsset.h"
#import "UNDPreferenceManager.h"

#import <BRControllerStack.h>
#import <BRComboMenuItemLayer.h>
#import <BRListControl.h>
#import <BRMenuController-HeaderConvienceMethods.h>
#import <BRMenuSavedState-Private.h>
#import <BRTextMenuItemLayer.h>

@implementation BRMenuSavedState (PrivateExpose)
- (NSMutableDictionary*) cachedMenuState
{
  BRMenuSavedState* shared = [BRMenuSavedState sharedInstance];
  return shared->_cachedMenuState;
}
@end

@interface UNDMenuController (Private)
- (void)attemptMenuRestore;
@end

@implementation UNDMenuController

- (id)initWithDelegate:(NSObject<UNDMenuDelegate>*)delegate
{
  [super init];
  delegate_ = [delegate retain];
  [self setListTitle:[delegate_ title]];
  UNDLoadingAsset* loading = [[[UNDLoadingAsset alloc] init] autorelease];
  assets_ = [[NSArray arrayWithObject:loading] retain];
  [[self list] setDatasource:self];
  lastrebuild_ = [[NSDate distantPast] retain];
  [self performSelectorInBackground:@selector(reload) withObject:nil];
  return self;
}

- (void)dealloc
{
  [delegate_ release];
  [lastrebuild_ release];
  [super dealloc];
}

- (void)reload
{
  NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
  if( [lastrebuild_ timeIntervalSinceNow] > (- 60 * 5)) return;
  reloadActive_ = YES;
  [lastrebuild_ autorelease];
  lastrebuild_ = [[NSDate date] retain];
  [assets_ autorelease];
  assets_ = [[delegate_ currentAssets] retain];
  [[self list] reload];
  [self updatePreviewController];
  [pool release];
  reloadActive_ = NO;
}

#pragma mark Controller

- (void)controlWasActivated
{
  [self reload];
  [super controlWasActivated];
  if (!reloadActive_) [self attemptMenuRestore];
  height_ = [[self stack] count];
}

- (void)controlWasDeactivated
{
  UNDPreferenceManager* preferences = [UNDPreferenceManager sharedInstance];
  BRControllerStack* stack = [self stack];
  if (!stack || ([stack count] < height_))  [preferences clearMenuState];
  [super controlWasDeactivated];
}

- (void)attemptMenuRestore
{
  UNDPreferenceManager* preferences = [UNDPreferenceManager sharedInstance];

  static BOOL first = YES;
  if (!first) return;
  first = NO;

  NSDictionary* cachedState = [preferences savedMenuState];
  if (!cachedState) return;
  NSArray* stack = [[BRMenuSavedState sharedInstance] stackPath];
  NSString* path = [stack componentsJoinedByString:@"/"];
  NSArray* selection = [cachedState objectForKey:path];
  NSString* selectionTitle = [selection objectAtIndex:0];
  NSNumber* selectionIndex = [selection objectAtIndex:1];
  int index = [selectionIndex integerValue];
  if (index >= [assets_ count]) return;
  NSObject<UnderstudyAsset>* asset = [assets_ objectAtIndex:index];
  if ([selectionTitle compare:[asset title]] == NSOrderedSame) {
    [[self list] setSelection:index];
    [[self stack] pushController:[asset controller]];
  }
}

- (void)itemSelected:(long)itemIndex
{
  if (![self rowSelectable:itemIndex]) return;
  BRController* controller;

  if ([[UNDManageDialog sharedInstance] assetManagementEnabled] &&
      [delegate_ isKindOfClass:[UNDMutableCollection class]])
  {
    UNDMutableCollection* collection = (UNDMutableCollection*)delegate_;
    controller = [[UNDEditDialog alloc] initWithCollection:collection
                                                  forIndex:itemIndex];
  } else {
    id<UnderstudyAsset> asset = [assets_ objectAtIndex:itemIndex];
    controller = [asset controller];
  }

  if (controller)
    [[self stack] pushController:controller];
}

- (BRControl*)previewControlForItem:(long)itemIndex
{
  if( ![self rowSelectable:itemIndex] ) return nil;
  BaseUnderstudyAsset* asset = [assets_ objectAtIndex:itemIndex];
  return [asset preview];
}

#pragma mark BRMenuListItemProvider
- (long)itemCount
{
  if( assets_ )
    return [assets_ count];
  else // if the assets haven't been loaded yet, we'll have a spinner
    return 1;
}

- (id)titleForRow:(long)row
{
  if( [self rowSelectable:row] )
    return [[assets_ objectAtIndex:row] title];
  else return @"Loading";//nil;
}

- (id)itemForRow:(long)row
{
  if ([assets_ count] == 0) return nil;
  if ([assets_ count] <= row) return nil;
  NSObject<UnderstudyAsset>* asset = [assets_ objectAtIndex:row];
  if( [asset respondsToSelector:@selector(menuItemForMenu:)] )
    return [asset menuItemForMenu:[delegate_ title]];
  else
    return [asset menuItem];
}

-(float)heightForRow:(long)row
{
  return 0;
}

-(BOOL)rowSelectable:(long)row
{
  return (row >= 0 && row < [assets_ count]);
}

- (BRMediaType*)mediaPreviewMissingMediaType{ return nil; }
- (BOOL)mediaPreviewShouldShowMetadata{ return YES; }
- (BOOL)mediaPreviewShouldShowMetadataImmediately{ return NO; }


@end
