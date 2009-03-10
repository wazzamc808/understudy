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

#define MARK_WIDTH 36
#define MARK_HEIGHT 26

- (id)initWithOrigin:(NSPoint)origin
{
  [super init];

  posCount_ = 5;
  positions_ = malloc( sizeof(NSPoint) * posCount_ );
  if( ! positions_ ){
    NSLog(@"failed to allocate positions");
    return nil;
  }
  
  positions_[0] = NSMakePoint(-MARK_WIDTH,-MARK_HEIGHT);
  positions_[1] = NSMakePoint(origin.x + 750,origin.y + 325);
  positions_[2] = NSMakePoint(origin.x + 750,origin.y + 250);
  positions_[3] = NSMakePoint(origin.x + 750,origin.y + 175);
  positions_[4] = NSMakePoint(origin.x + 750,origin.y + 100);
  currentPos_ = 0;
  
  NSRect rect;
  rect.origin = origin;
  rect.size.height = MARK_HEIGHT;
  rect.size.width = MARK_WIDTH;
  
  window_ = [[NSWindow alloc] initWithContentRect:rect
                                        styleMask:0
                                          backing:NSBackingStoreBuffered
                                            defer:YES];
  [window_ setBackgroundColor:[NSColor redColor]];
  [window_ setAlphaValue:0.4];
  return self;
}

- (void)dealloc
{
  [window_ close];
  free(positions_);
  [super dealloc];
}

- (void)show
{
  NSPoint point;
  point.x = positions_[currentPos_].x - MARK_WIDTH/2;
  point.y = positions_[currentPos_].y - MARK_HEIGHT/2;
  [window_ setFrameOrigin:point];
  [window_ display];
  [window_ setLevel:NSScreenSaverWindowLevel];
  [window_ orderFrontRegardless];
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
- (NSWindow*)window{ return window_; }

// the 0th position is offscreen and invalid.
- (BOOL)locationIsValid{ return currentPos_ != 0; }
@end
