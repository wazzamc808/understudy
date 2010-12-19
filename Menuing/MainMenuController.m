//
//  Copyright 2008-2010 Kirk Kelsey.
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

#import "UNDAssetFactory.h"
#import "UNDExternalAppAssetProvider.h"
#import "UNDHuluAssetProvider.h"
#import "UNDNetflixAssetProvider.h"
#import "UNDYouTubeAssetProvider.h"
#import "UNDiPlayerAssetProvider.h"

#import "MainMenuController.h"
#import "ManageFeedsDialog.h"

#import <BRControllerStack.h>
#import <BRListControl.h>
#import <BRMenuSavedState-Private.h>
#import <BRTextMenuItemLayer.h>

@interface MainMenuController (PrivateMenuHandling)
- (void)loadAssets;
@end

@implementation MainMenuController

- (id)init
{
  [super init];
  preferences_ = [UNDPreferenceManager sharedInstance];
  [preferences_ addSubscriber:self];
  [self loadAssets];
  [self setListTitle:@"Understudy"];
  [[self list] setDatasource:self];
  return self;
}

- (void)dealloc
{
  [assets_ release];
  [super dealloc];
}

// we'll assume that FR won't try to release or copy the controller
static MainMenuController *sharedInstance_;
+ (MainMenuController*)sharedInstance
{
  if(!sharedInstance_) {
    UNDAssetFactory* factory = [UNDAssetFactory sharedInstance];
    [factory registerProvider:[[UNDExternalAppAssetProvider alloc] init]];
    [factory registerProvider:[[UNDHuluAssetProvider alloc] init]];
    [factory registerProvider:[[UNDNetflixAssetProvider alloc] init]];
    [factory registerProvider:[[UNDYouTubeAssetProvider alloc] init]];
    [factory registerProvider:[[UNDiPlayerAssetProvider alloc] init]];
    sharedInstance_ = [[MainMenuController alloc] init];
  }
  return sharedInstance_;
}

- (void)loadAssets
{
  NSArray* descriptions = [preferences_ assetDescriptions];
  [assets_ autorelease];
  assets_ = [[NSMutableArray arrayWithCapacity:[descriptions count]] retain];
  int count = [descriptions count];

  UNDAssetFactory* factory = [UNDAssetFactory sharedInstance];
  for (NSDictionary* description in descriptions) {
    id<UnderstudyAsset> asset =  [factory assetForContent:description];
    if (asset) [assets_ addObject:asset];
  }
  [assets_ addObject:[[[ManageFeedsDialog alloc] init] autorelease]];

  [[self list] removeDividers];
  [[self list] addDividerAtIndex:count withLabel:nil];
  [[self list] reload];
}

// if the asset hasn't actually been loaded, create it how
- (NSObject<UnderstudyAsset>*)assetForRow:(long)row
{
  NSObject<UnderstudyAsset>* asset = [assets_ objectAtIndex:row];
  return asset;
}

- (void)preferencesDidChange
{
  [self loadAssets];
}

#pragma mark Back Row subclassing

- (long)itemCount
{
  return [assets_ count];
}

- (id)titleForRow:(long)row
{
  return [(BRTextMenuItemLayer*)[self itemForRow:row] title];
}

- (id)itemForRow:(long)row
{
  NSObject<UnderstudyAsset>* asset = [assets_ objectAtIndex:row];
  return [asset menuItem];
}

-(float)heightForRow:(long)row
{
  return 0; //0 tells FR to use its standard height
}

-(BOOL)rowSelectable:(long)row
{
  return YES;
}

- (void)itemSelected:(long)itemIndex
{
  NSObject<UnderstudyAsset>* asset = [assets_ objectAtIndex:itemIndex];
  [[self stack] pushController:[asset controller]];
}

- (BRControl*)previewControlForItem:(long)itemIndex
{
  BaseUnderstudyAsset<UnderstudyAsset>* asset;
  asset = [assets_ objectAtIndex:itemIndex];
  if( [asset respondsToSelector:@selector(preview)] )
    return [asset preview];
  else
    return nil;
}

-(void)controlWasActivated
{
  [super controlWasActivated];

  static BOOL first = YES;
  if (!first) return;
  first = NO;

  NSDictionary* cachedState = [preferences_ savedMenuState];
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
    [self setSelectedItem:index];
    [[self stack] pushController:[asset controller]];
  }
}

- (void) controlWasDeactivated
{
  if ([[self stack] count] < 2) [preferences_ clearMenuState];
  [super controlWasDeactivated];
}

@end
