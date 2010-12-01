//
//  DailyShowAddDialog.h
//  understudy
//
//  Created by jb on 11/5/10.
//  Copyright 2010 Jason Brown. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <BRMenuListItemProvider-Protocol.h>
#import <BRCenteredMenuController.h>

@interface DailyShowAddDialog : BRCenteredMenuController 
<BRMenuListItemProvider> {
  NSMutableArray* titles_;
  NSMutableArray* feeds_;
}

@end
