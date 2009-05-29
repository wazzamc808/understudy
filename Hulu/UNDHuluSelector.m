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

#import "UNDHuluSelector.h"


@implementation UNDHuluSelector

- (id)initWithView:(NSView*)view
{
  if( !view ) return nil;

  [super init];

  posCount_ = 5;
  positions_ = malloc( sizeof(NSPoint) * posCount_ );
  if( ! positions_ ) return nil;
  
  view_ = [view retain];
  NSWindow* window = [view window];
  NSScreen* screen = [window screen];
  screenHeight_ = [screen frame].size.height;

  positions_[0] = NSMakePoint(0,0);
  positions_[1] = NSMakePoint(755,20);
  positions_[2] = NSMakePoint(755,95);
  positions_[3] = NSMakePoint(755,170);
  positions_[4] = NSMakePoint(755,245);

  int i;
  for( i=1; i < posCount_; i++ ){
    positions_[i] = [view convertPointToBase:positions_[i]];
    positions_[i] = [window convertBaseToScreen:positions_[i]];
  }
  currentPos_ = 0;
  return self;
}

- (void)dealloc
{
  free(positions_);
  [view_ release];
  [super dealloc];
}

- (void)show
{
  CGPoint point;
  point.x = positions_[currentPos_].x;
  point.y = screenHeight_ - positions_[currentPos_].y;
  CGPostMouseEvent(point,1,1,0);
}

- (void)hide
{
  currentPos_ = 0;
  [self show];
}

- (void)nextPosition
{
  currentPos_ = (currentPos_+1) % posCount_;
  [self show];
}

- (void)prevPosition
{
  currentPos_ = (posCount_ + currentPos_-1) % posCount_;
  [self show];
}

- (NSPoint)location{ return positions_[currentPos_];}

// the 0th position is offscreen and invalid.
- (BOOL)locationIsValid{ return currentPos_ != 0; }

- (void)select
{
  CGPoint cg;
//  NSPoint point = positions_[currentPos_];
  cg.x = positions_[currentPos_].x;
  cg.y = screenHeight_ - positions_[currentPos_].y;
  CGPostMouseEvent(cg,1,1,1);
  CGPostMouseEvent(cg,1,1,0);    

  // NSPoint fsPoint = [view_ convertPointFromBase:[selector_ location]];

  // [pluginControl_ sendPluginMouseClickAtPoint:fsPoint];
  // [pluginControl_ sendPluginMouseClickAtPoint:fsPoint];
}

@end
