//
//  Copyright 2009-2011 Kirk Kelsey.
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

#import "UNDMenuController.h"

#import <BRControllerStack.h>
#import <BRComboMenuItemLayer.h>
#import <BRListControl.h>
#import <BRMenuController-HeaderConvienceMethods.h>
#import <BRMenuSavedState-Private.h>
#import <BRTextMenuItemLayer.h>

#import "UNDAsset.h"
#import "UNDBaseAsset.h"
#import "UNDBaseController.h"
#import "UNDEditDialog.h"
#import "UNDManageDialog.h"
#import "UNDLoadingAsset.h"
#import "UNDPreferenceManager.h"

@implementation BRMenuSavedState (PrivateExpose)
- (NSMutableDictionary*) cachedMenuState
{
  BRMenuSavedState* shared = [BRMenuSavedState sharedInstance];
  return shared->_cachedMenuState;
}
@end

@interface UNDMenuController (Private)
-(void)attemptMenuRestore;
-(void)maybeReloadAssets;
-(void)reloadView;
@end

@implementation UNDMenuController

- (id)initWithDelegate:(NSObject<UNDMenuDelegate>*)delegate
{
  [super init];
  delegate_ = [delegate retain];
  [self setListTitle:[delegate_ title]];
  UNDLoadingAsset* loading = [[[UNDLoadingAsset alloc] init] autorelease];
  assets_ = [[NSMutableArray arrayWithObject:loading] retain];
  [[self list] setDatasource:self];

  lastrebuild_ = [[NSDate distantPast] retain];
  [self performSelectorInBackground:@selector(maybeReloadAssets)
                         withObject:nil];

  if ([delegate_ isKindOfClass:[UNDMutableCollection class]])
    mutable_ = YES;

  return self;
}

- (void)dealloc
{
  [delegate_ release];
  [lastrebuild_ release];
  [super dealloc];
}

/// Calls reloadAssets if enough time has passed.
- (void)maybeReloadAssets
{
  if (reloadActive_) return;
  NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
  if ([lastrebuild_ timeIntervalSinceNow] < (- 60 * 5))
    [self reloadAssets];
  [pool release];
}

// Updates the asset list and indicates that view refresh is necessary.
- (void)reloadAssets
{
  reloadActive_ = YES;
  [lastrebuild_ autorelease];
  lastrebuild_ = [[NSDate date] retain];
  [assets_ autorelease];
  assets_ = [[delegate_ currentAssets] retain];
  assetsUpdated_ = YES;
  reloadActive_ = NO;
  if ([self active]) [self reloadView];
}

/// Updates the view if the assets have changed.
- (void)reloadView
{
  if (assetsUpdated_) {
    assetsUpdated_ = NO;
    [[self list] reload];
    if (mutable_) {
      [[self list] removeDividers];
      [[self list] addDividerAtIndex:[assets_ count] withLabel:nil];
    }
    [self updatePreviewController];
  }
}

#pragma mark Controller

- (void)controlWasActivated
{
  [self maybeReloadAssets];
  [self reloadView];
  [super controlWasActivated];
  if (!reloadActive_) [self attemptMenuRestore];
  height_ = [[self stack] count];
}

- (void)controlWasDeactivated
{
  UNDPreferenceManager* preferences = [UNDPreferenceManager sharedInstance];
  BRControllerStack* stack = [self stack];
  if (!stack || ([stack count] < height_)) [preferences clearMenuState];
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
  if (![self rowSelectable:index]) return;

  NSObject<UNDAsset>* asset = [assets_ objectAtIndex:index];
  if ([selectionTitle compare:[asset title]] == NSOrderedSame) {
    [[self list] setSelection:index];
    [[self stack] pushController:[asset controller]];
  }
}

- (NSObject<UNDAsset>*)assetForIndex:(long)index
{
  if (![self rowSelectable:index]) return nil;
  if (index == [assets_ count]) return [UNDManageDialog sharedInstance];
  return [assets_ objectAtIndex:index];
}

- (void)itemSelected:(long)itemIndex
{
  if (![self rowSelectable:itemIndex]) return;
  BRController* controller;
  UNDManageDialog* manager = [UNDManageDialog sharedInstance];

  // The manage dialog hangs off the end of the asset array.
  if (itemIndex == [assets_ count]) {
    if (mutable_)
      [manager setCollection:(UNDMutableCollection*)delegate_];
    controller = manager;
  } else if ([manager assetManagementEnabled] && mutable_) {
    UNDMutableCollection* collection = (UNDMutableCollection*)delegate_;
    controller = [[[UNDEditDialog alloc]
                    initWithCollection:collection forIndex:itemIndex]
                   autorelease];
  } else {
    id<UNDAsset> asset = [assets_ objectAtIndex:itemIndex];
    controller = [asset controller];
  }

  if (controller)
    [[self stack] pushController:controller];
}

- (BRControl*)previewControlForItem:(long)itemIndex
{
  return [[self assetForIndex:itemIndex] preview];
}

#pragma mark BRMenuListItemProvider
- (long)itemCount
{
  if (assets_) {
    int count = [assets_ count];
    if (mutable_) ++count;      // Mutable collections get an edit dialog
    return count;
  }
  return 0;
}

- (id)titleForRow:(long)row
{
  return [[self assetForIndex:row] title];
}

- (id)itemForRow:(long)row
{
  NSObject<UNDAsset>* asset = [self assetForIndex:row];
  if ([asset respondsToSelector:@selector(menuItemForMenu:)])
    return [asset menuItemForMenu:[delegate_ title]];

  return [asset menuItem];
}

-(float)heightForRow:(long)row
{
  (void)row;
  return 0;
}

-(BOOL)rowSelectable:(long)row
{
  return (row >= 0 && row < [self itemCount]);
}

- (BRMediaType*)mediaPreviewMissingMediaType{ return nil; }
- (BOOL)mediaPreviewShouldShowMetadata{ return YES; }
- (BOOL)mediaPreviewShouldShowMetadataImmediately{ return NO; }


@end
