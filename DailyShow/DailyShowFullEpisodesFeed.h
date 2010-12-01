//
//  DailyShowFullEpisodesDialog
//  understudy
//
//  Created by jb on 11/5/10.
//  Copyright 2010 Jason Brown. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <BRMediaMenuController.h>

#import "BaseUnderstudyAsset.h"
#import "FeedMenuController.h"
#import "DailyShowAsset.h"

@class BRTextMenuItemLayer;

@interface DailyShowFullEpisodesFeed : BaseUnderstudyAsset
<FeedDelegate>
{
@private
  NSMutableArray* assets_;
  NSURL* url_;
  NSString* title_;
  FeedMenuController* controller_;
}

- (id)initWithTitle:(NSString*)title forUrl:(NSURL*)url;

@end
