//
//  MainMenuController.h
//  Understudy FR Appliance
//
//  Created by Kirk Kelsey.
//  Copyright 2008. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <BackRow/BRMediaMenuController.h>
#import <BackRow/BROptionDialog.h>
#import <BackRow/BRTextEntryController.h>

// class MainMenuController
//
// The primary window returned by the appliance controller. Use the
// sharedInstance method to access the menu singleton rather than init (which 
// is the designated initializer.

@interface MainMenuController : BRMediaMenuController
<BRMenuListItemProvider, BRTextEntryDelegate> 
{
 @private
  NSMutableArray* items_;
  NSMutableArray* feeds_;
  NSMutableDictionary* controllers_;
  BRTextEntryController* addController_;
  BROptionDialog* removeDialog_;
  NSString* newfeed_;
}

// Singleton access
+ (MainMenuController*)sharedInstance;

@end
