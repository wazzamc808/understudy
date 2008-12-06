//
//  FeedMenuController.m
//  Understudy FR Appliance
//
//  Created by Kirk Kelsey.
//  Copyright 2008. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <BackRow/BRMediaMenuController.h>

@class BRTextMenuItemLayer;

@interface FeedMenuController : BRMediaMenuController<BRMenuListItemProvider>
{
  NSURL* _url;
  NSMutableArray* _items;
  NSMutableArray* _assets;
  NSDate* _lastrebuild;
}

- (id)initWithUrl:(NSURL*)url;

@end
