//
//  VideoController.h
//  Understudy FR Appliance
//
//  Created by Kirk Kelsey.
//  Copyright 2008. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

#import "BackRow/BRController.h"

#import "VideoAsset.h"

@interface VideoController : BRController {
 @private
  VideoAsset* asset_;
  NSWindow* window_;
  WebView* view_;
  WebView* pluginView_;
}

- (id)initWithVideoAsset:(VideoAsset*)asset;

@end
