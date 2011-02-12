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
//  along with Understudy.  If not, see <http://www.gnu.org/licenses/>.

#import "UNDManageDialog.h"
#import "UNDPreferenceManager.h"
#import "UNDRenameDialog.h"

#import <BRControllerStack.h>
#import <BRMenuListItemProvider-Protocol.h>
#import <BRListControl.h>
#import <BRTextMenuItemLayer.h>

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
    [[self stack] pushController:addController_];
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

#pragma mark MenuListItemProvider

- (long)itemCount{ return kOptionCount; }
- (float)heightForRow:(long)row{ return 0; }
- (BOOL)rowSelectable:(long)row
{
  int count
    = [[[UNDPreferenceManager sharedInstance] assetDescriptions] count];
  return (row == 0 || count > 0);
}

- (id)titleForRow:(long)row
{
  ManageOption option = (ManageOption)row;
  switch (option) {
  case kAddOption:
    return @"Add asset to the main menu";
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
  return nil;
}

@end
