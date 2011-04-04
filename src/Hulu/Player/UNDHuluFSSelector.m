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

#import "UNDHuluFSSelector.h"

@implementation UNDHuluFSSelector

// update the mouse position
- (void)updateCursor
{
  CGPoint cg;
  cg.x = currentPosition_.x;
  cg.y = frame_.size.height - currentPosition_.y;
  CGPostMouseEvent(cg,1,1,0);
}

// put the cursor back in the invalid position. this should be done 
// automatically after some delay in user input
- (void)reset
{
  currentPosition_ = NSMakePoint(0,0);
  [self updateCursor];
}

- (void)nextPosition
{
  [NSObject cancelPreviousPerformRequestsWithTarget:self];
  if( ![self locationIsValid] ){
    currentPosition_ = NSMakePoint(10,10);
  }else{
    double width = frame_.size.width;
    currentPosition_.x += width/10;
  }
  [self updateCursor];
  [self performSelector:@selector(reset) withObject:nil afterDelay:3];
}

- (void)prevPosition
{
  [NSObject cancelPreviousPerformRequestsWithTarget:self];
  double width = frame_.size.width;
  currentPosition_.x -= width/10;
  if( currentPosition_.x <= 5 ) currentPosition_ = NSMakePoint(0,0);
  [self updateCursor];
  [self performSelector:@selector(reset) withObject:nil afterDelay:3];
}

- (NSPoint)location
{
  return currentPosition_;
}

- (BOOL)locationIsValid
{
  if( currentPosition_.x == 0 )
    return NO;
  else
    return YES;
}

- (void)select
{
  CGPoint cg;
  cg.x = currentPosition_.x;
  cg.y = frame_.size.height - currentPosition_.y;
  CGPostMouseEvent(cg,1,1,1);
  CGPostMouseEvent(cg,1,1,0);    
}

- (id)initWithScreen:(NSScreen*)screen
{
  [super init];
  frame_ = [screen frame];
  [self reset];
  return self;
}

@end
