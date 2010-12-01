//
//  DailyShowAsset.h
//  understudy
//
//  Created by jb on 11/5/10.
//  Copyright 2010 Jason Brown. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <BRBaseMediaAsset.h>
#import <BRImageManager.h>
#import <BRMediaAsset-Protocol.h>
#import <BRTextMenuItemLayer.h>

#import "BaseUnderstudyAsset.h"
#import "UnderstudyAsset.h"

// class DailyShowAsset
//
// Represents the attributes of a Netflix Video

@class DailyShowAsset;

@interface DailyShowAsset : BaseUnderstudyAsset <UnderstudyAsset> {
@private
  NSString* title_;
  NSString* description_;
  NSURL* url_;
  NSString* thumbnailID_;
  BRTextMenuItemLayer* menuitem_;
  BRImageManager* imageManager_;
  BOOL startsWithSpinner_;
}

- (id)initWithTitle:(NSString*)title description:(NSString*)desc
             forUrl:(NSString*)url forImage:(NSString*)image; 

// Provides the primary url of the media.
- (NSURL*)url;

@end
