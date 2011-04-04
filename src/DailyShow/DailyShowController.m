//  Copyright 2011 Jason Brown.
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

#import <stdint.h>

#import "UNDPluginControl.h"
#import "UNDPreferenceManager.h"
#import "DailyShowController.h"
#import "DailyShowAsset.h"

@implementation DailyShowController

#define BASEHTML @" \
    <html> \
    <head> \
    <style type=\"text/css\"> \
      body { margin: 0; padding: 0; } \
    </style> \
    </head> \
    <body onLoad=\"document.body.focus();\"> \
      <object \
        id=\"full_ep_video_player\" \
        type=\"application/x-shockwave-flash\" \
        classid=\"clsid:D27CDB6E-AE6D-11cf-96B8-444553540000\" \
        width=\"%f\" \
        height=\"%f\" \
        xmlns:media=\"http://search.yahoo.com/searchmonkey/media/\" \
        rel=\"media:video\" \
        resource=\"%@\" \
        xmlns:dc=\"http://purl.org/dc/terms/\"> \
        <param name=\"movie\" value=\"%@\"/> \
        <param name=\"wmode\" value=\"opaque\"/> \
        <param name=\"bgcolor\" value=\"#000000\"/> \
        <param name=\"seamlesstabbing\" value=\"true\"/> \
        <param name=\"swliveconnect\" value=\"true\"/> \
        <param name=\"allowscriptaccess\" value=\"always\"/> \
        <param name=\"allownetworking\" value=\"all\"/> \
        <param name=\"allowfullscreen\" value=\"true\"/> \
        <param name=\"flashvars\" value=\"sid=The_Daily_Show_Full_Eps&amp;autoPlay=true&amp;configParams=site%3Dthedailyshow.com\"/> \
    </body> \
    </html>"

- (id)initWithAsset:(DailyShowAsset*)asset
{
  [super init];
  asset_ = [asset retain];
  return self;
}

- (void)dealloc
{
  [asset_ release];
  asset_ = nil;
  [pluginControl_ release];
  pluginControl_ = nil;
  [super dealloc];
}

// <WebFrameLoadDelegate> callback once the video loads
- (void)webView:(WebView*)view didFinishLoadForFrame:(WebFrame*)frame
{
  NSLog( @"DailyShowController:didFinishLoadForFrame called." );
  if( frame != [view mainFrame] ) return;
  [window_ display];
  [window_ orderFrontRegardless];
  [window_ setLevel:NSScreenSaverWindowLevel];
//  [window_ setLevel:CGShieldingWindowLevel()];
  
  [self reveal];
  
  NSLog( @"DailyShowController:didFinishLoadForFrame done." );  
}

// <WebFrameLoadDelegate> callback for errors
- (void)webView:(WebView *)sender didFailLoadWithError:(NSError *)error 
       forFrame:(WebFrame *)frame
{
  NSLog( @"DailyShowController:didFailLoadWithError: %@, %d, %@", 
        [error localizedDescription],
        [error code],
        [error domain] );
  [self playPause];
}

- (void)controlWillActivate
{
  [super controlWillActivate];

  [NSApplication sharedApplication];

  NSRect rect = [[UNDPreferenceManager screen] frame];

  NSString *pageHTML = [NSString stringWithFormat:BASEHTML,
                        rect.size.width, rect.size.height,
                        [asset_ url], [asset_ url]];
  NSLog( @"DailyShowController: load html: %@", pageHTML );

  WebView* mainView = [[WebView alloc] initWithFrame:rect];
  [[[mainView mainFrame] frameView] setAllowsScrolling:NO];
  [mainView setFrameLoadDelegate:self];

  window_ = [[NSWindow alloc] initWithContentRect:rect
                                         styleMask:0
                                           backing:NSBackingStoreBuffered
                                             defer:YES];

  [window_ setContentView:mainView];
  [[mainView mainFrame] loadHTMLString:pageHTML baseURL:nil];
  pluginControl_ = [[UNDPluginControl alloc] initWithView:mainView];
  NSLog( @"DailyShowController:controlWillActivate done." );
}

- (void)controlWillDeactivate
{
  [super controlWillDeactivate];
  
  NSLog( @"DailyShowController:controlWillDeactivate called." );
  [self returnToFR];
  [window_ close];
  window_ = nil;
  //  [window_ setContentSize:NSMakeSize(640.0, 480.0)];
  NSLog( @"DailyShowController:controlWillDeactivate done." );
}

- (void)playPause
{
  NSLog( @"DailyShowController:playPause called." );
  
  CGPoint point = CGPointMake( 500, 500 );
  
  CGEventRef event = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseDown, point, kCGMouseButtonLeft);
  
  CGEventSetType(event, kCGEventLeftMouseDown);
  CGEventPost(kCGHIDEventTap, event);
  
  CGEventSetType(event, kCGEventLeftMouseUp);
  CGEventPost(kCGHIDEventTap, event);
  
  CFRelease(event);
  
  [pluginControl_ sendPluginKeyCode:49 withCharCode:0];  // space-bar
}

// skip 10% of the way through the video
//- (void)fastForward
//{
//  NSLog( @"DailyShowController:fastForward called." );
  //if( !loaded_ ) return;
//  NSNumber* time = [self _playerFunction:@"getCurrentTime()"];
//  NSNumber* duration = [self _playerFunction:@"getDuration()"];
//  int target = [time intValue] + ([duration intValue])/10;
//  NSString* seek = [NSString stringWithFormat:@"seekTo(%d,true)",target];
//  [self _playerFunction:seek];
//  NSLog( @"DailyShowController:fastForward done." );
//}
//
//// jump back 5% of the way to the beginning of the video
//- (void)rewind
//{
//  NSLog( @"DailyShowController:rewindForward called." );
//  if( !loaded_ ) return;
//  NSNumber* time = [self _playerFunction:@"getCurrentTime()"];
//  NSNumber* duration = [self _playerFunction:@"getDuration()"];
//  int target = [time intValue] + ([duration intValue])/20;
//  NSString* seek = [NSString stringWithFormat:@"seekTo(%d,true)",target];
//  [self _playerFunction:seek];  
//  NSLog( @"DailyShowController:rewind done." );
//}

@end
