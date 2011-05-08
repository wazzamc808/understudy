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
//  FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License
//  for more details.
//
//  You should have received a copy of the GNU Lesser General Public License
//  along with Understudy. If not, see <http://www.gnu.org/licenses/>.

#import "Base/UNDManageDialog.h"

#import <BRHeaders/BRControllerStack.h>
#import <BRHeaders/BRMenuListItemProvider-Protocol.h>
#import <BRHeaders/BRListControl.h>
#import <BRHeaders/BRMediaPreviewControllerFactory.h>
#import <BRHeaders/BRTextMenuItemLayer.h>

#import "Utilities/UNDIconProvider.h"
#import "Utilities/UNDPreferenceManager.h"

@implementation UNDManageDialog

typedef enum
{
  kAddOption = 0,
  kEnableOption,
  kOptionCount // this must be immediately after the last valid option
} ManageOption;

- (id)init
{
  [super init];
  [self setTitle:[self title]];
  [self setIcon:UNDIcon() horizontalOffset:0.0 kerningFactor:0.0];
  addController_ = [[UNDAddAssetDialog alloc] init];
  [[self list] setDatasource:self];
  return self;
}

#pragma mark Controller

- (void)itemSelected:(long)index
{
  ManageOption option = (ManageOption)index;
  switch( option )
  {
  case kAddOption:
    [addController_ setCollection:collection_];
    [[self stack] swapController:addController_];
    break;
  case kEnableOption:
    enabled_ = !enabled_;
    [[self stack] popController];
    break;
  case kOptionCount:
    break;
  }
}

- (void)controlWillActivate
{
  [super controlWillActivate];
  [[self list] reload];
  if( ![self rowSelectable:[self selectedItem]] )
    [self setSelectedItem:0];
}

- (void)controlWasDeactivated
{
  [super controlWasDeactivated];
  collection_ = nil;
}

-(BOOL)assetManagementEnabled
{
  return enabled_;
}

-(void)disableAssetManagement
{
  enabled_ = NO;
}

static UNDManageDialog* sharedInstance_;
+ (UNDManageDialog*)sharedInstance
{
  if (!sharedInstance_)
    sharedInstance_ = [[UNDManageDialog alloc] init];

  return sharedInstance_;
}

-(void)setCollection:(UNDMutableCollection*)collection
{
  collection_ = collection;
}

#pragma mark MenuListItemProvider

- (long)itemCount{ return kOptionCount; }
- (float)heightForRow:(long)row
{
  (void)row;
  return 0; 
}

- (BOOL)rowSelectable:(long)row
{
  switch (row) {
  case kAddOption:
    if (collection_) return YES;
    return NO;
  case kEnableOption:
    return YES;
  case kOptionCount:
    return NO;
  }
  return NO;
}

- (id)titleForRow:(long)row
{
  ManageOption option = (ManageOption)row;
  switch (option) {
  case kAddOption:
    return @"Add entry to this collection";
  case kEnableOption:
    if (enabled_) return @"Disable management dialogs";
    return @"Enable management dialogs";
  case kOptionCount:
    break;
  }
  return @"";
}

- (id)itemForRow:(long)row
{
  BRTextMenuItemLayer* item = [BRTextMenuItemLayer menuItem];
  [item setTitle:[self titleForRow:row]];
  return item;
}

#pragma mark Understudy Asset
- (BRLayer<BRMenuItemLayer>*)menuItem
{
  BRTextMenuItemLayer* manager = [BRTextMenuItemLayer menuItem];
  [manager setTitle:[self title]];
  return manager;
}

- (BRController*)controller{ return self; }

- (NSString*)title
{
  return @"Manage Assets";
}

- (NSArray*)containedAssets
{
  return nil;
}

- (BRControl*)preview
{
  if (!preview_) {
    preview_ = [BRMediaPreviewControllerFactory
                 previewControlForAsset:self withDelegate:self];
    [preview_ retain];
  }
  return preview_;
}

- (BOOL)hasCoverArt { return YES; }
- (BRImage*)coverArt { return UNDIcon(); }
- (NSString*)coverArtID { return UNDIconID(); }

- (id)mediaPreviewMissingMediaType{ return nil; }
- (BOOL)mediaPreviewShouldShowMetadata{ return YES; }
- (BOOL)mediaPreviewShouldShowMetadataImmediately{ return YES; }

@end
