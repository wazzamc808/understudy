//
//  Copyright 2008-2009 Kirk Kelsey.
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

#import "HuluFeed.h"
#import "NetflixFeed.h"
#import "YouTubeFeed.h"

#import "MainMenuController.h"
#import "ManageFeedsDialog.h"

#import <BackRow/BRControllerStack.h>
#import <BackRow/BRTextMenuItemLayer.h>
#import <BackRow/RUIPreferences.h>

@interface MainMenuController (PrivateMenuHandling)
- (void)loadAssets;
- (NSObject<UnderstudyAsset>*)assetForRow:(long)row;
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
  if(!sharedInstance_) sharedInstance_ = [[MainMenuController alloc] init];
  return sharedInstance_;
}

- (void)loadAssets
{  
  int i = 0, count = [preferences_ feedCount];
  [assets_ autorelease];
  assets_ = [[NSMutableArray arrayWithCapacity:count] retain];
  for( i=0; i<count; i++ ) [assets_ addObject:[NSNull null]];
  [assets_ addObject:[[[ManageFeedsDialog alloc] init] autorelease]];
  [[self list] removeDividers];
  [[self list] addDividerAtIndex:count withLabel:nil];
  [[self list] reload];
}

- (NSObject<UnderstudyAsset>*)assetForRow:(long)row
{
  NSObject<UnderstudyAsset>* asset = [assets_ objectAtIndex:row];
  if( (id)asset == (id)[NSNull null] ){
    NSURL* url = [preferences_ URLAtIndex:row];
    NSString* title = [preferences_ titleAtIndex:row];
    NSString* host = [[url host] lowercaseString];
    
    if( [host rangeOfString:@"hulu"].location != NSNotFound )
      asset = [[HuluFeed alloc] initWithTitle:title forUrl:url];
    else if( [host rangeOfString:@"netflix"].location != NSNotFound )
      asset = [[NetflixFeed alloc] initWithTitle:title forUrl:url];
    else if( [host rangeOfString:@"youtube"].location != NSNotFound )
      asset = [[YouTubeFeed alloc] initWithTitle:title forUrl:url];
    else asset = (BaseUnderstudyAsset<UnderstudyAsset>*)[NSNull null];
    
    [assets_ replaceObjectAtIndex:row withObject:asset];
    [asset autorelease];
  }
  return asset;
}

- (void)preferencesDidChange
{
  [self loadAssets];
}

#pragma mark Back Row subclassing
  
- (long)itemCount
{
  return 1+[preferences_ feedCount];
}

- (NSString*)titleForRow:(long)row
{
  return [(BRTextMenuItemLayer*)[self itemForRow:row] title];
}

- (BRLayer<BRMenuItemLayer>*)itemForRow:(long)row
{
  NSObject<UnderstudyAsset>* asset = [self assetForRow:row];
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
  NSObject<UnderstudyAsset>* asset = [self assetForRow:itemIndex];
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

@end
