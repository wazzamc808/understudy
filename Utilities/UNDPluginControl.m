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

#import <Carbon/Carbon.h>

#import "UNDPluginControl.h"

@implementation UNDPluginControl

- (id)initWithView:(WebView*)view
{
  [super init];
  mainView_ = [view retain];
  return self;
}

- (void)dealloc
{
  [mainView_ release];
  [super dealloc];
}

- (id)plugin
{
  if( pluginView_ ) return pluginView_;
  if( !mainView_ ) return nil;

  NSMutableSet* views = [[[NSMutableSet set] retain] autorelease];
  NSMutableSet* plugins = [[[NSMutableSet set] retain] autorelease];
  WebView* view;
  [views addObjectsFromArray:[mainView_ subviews]];
  while( [views count] ){
    view = [views anyObject];
    if( [[view className] isEqual:@"WebNetscapePluginDocumentView"] )
        [plugins addObject:view];
    [views addObjectsFromArray:[view subviews]];
    [views removeObject:view];
  }
  if( [plugins count] < 1 ){
    NSLog(@"could not a find a plugin");
  }else if( [plugins count] > 1 ){
    pluginView_ = [[plugins anyObject] retain];
    float pluginsize = ([pluginView_ frame].size.height * [pluginView_ frame].size.width);
    // pick the largest plugin view available
    for( view in plugins )
    {
      NSSize size = [view frame].size;
      NSPoint orig = [view frame].origin;
      if( orig.x+size.width < 0
         || orig.y+size.height < 0
         || orig.x > [mainView_ frame].size.width
         || orig.y > [mainView_ frame].size.height )
        continue;
      if( size.height*size.width > pluginsize )
      {
        [pluginView_ autorelease];
        pluginView_ = [view retain];
        pluginsize = size.height*size.width;
      }
    }
  }else{
    pluginView_ = [[plugins anyObject] retain];
  }
  return pluginView_;
}

- (void)sendPluginKeyCode:(int)keyCode
             withCharCode:(int)charCode
             andModifiers:(int)modifiers
{
  if( ![self plugin] )return;
  if( ![pluginView_ respondsToSelector:@selector(sendEvent:)] ) return;
  EventRecord event;
  event.what = keyDown;
  event.message = (keyCode << 8) + charCode;
  event.modifiers = modifiers;
  [(id)pluginView_ sendEvent:(NSEvent *)&event];
  event.what = keyUp;
  [(id)pluginView_ sendEvent:(NSEvent *)&event];
}

- (void)sendPluginKeyCode:(int)keyCode withCharCode:(int)charCode
{
  [self sendPluginKeyCode:keyCode withCharCode:charCode andModifiers:0];
}

// click on the plugin view at a given point in it's own coordinate space
// (0,0) is top left, but negative values are measured from the bottom/right
- (void)sendPluginMouseClickAtPoint:(NSPoint)point
{
  if( ![pluginView_ respondsToSelector:@selector(sendEvent:)] ) return;
  EventRecord record;
  NSPoint orig = [pluginView_ frame].origin;
  record.modifiers = btnState;
  record.message = 0;
  record.what = mouseDown;
  record.when = TickCount();
  record.where.h = orig.x + point.x;
  record.where.v = orig.y + point.y;

  [pluginView_ sendEvent:(NSEvent *)&record];
  record.what = mouseUp;
  record.when = TickCount();
  [pluginView_ sendEvent:(NSEvent *)&record];
}
@end
