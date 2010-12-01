//
//  DailyShowController.h
//  understudy
//
//  Created by jb on 11/12/10.
//  Copyright 2010 Jason Brown. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

#import "BaseController.h"
#import "UNDPluginControl.h"
#import "RemoteControl.h"

@class DailyShowAsset;

@interface DailyShowController : BaseController
{
  DailyShowAsset *asset_; //weak reference
//  WebView *view_;
  NSWindow *window_;      //original window
  UNDPluginControl *pluginControl_;
}

- (id)initWithAsset:(DailyShowAsset*)asset;

//- (void)fullScreen;

@end
