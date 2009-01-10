//
//  Copyright 2009 Kirk Kelsey.
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

#import "YouTubeControlDelegate.h"
#import "YouTubeAsset.h"

@implementation YouTubeControlDelegate

- (id)initWithAsset:(YouTubeAsset*)asset
{
  [super init];
  asset_ = asset;
  return self;
}

- (void)load
{
  NSLog(@"load");
  [NSApplication sharedApplication];
  NSRect rect = [[NSScreen mainScreen] frame];
  view_ = [[WebView alloc] initWithFrame:rect];
  [[[view_ mainFrame] frameView] setAllowsScrolling:NO];
  [view_ setFrameLoadDelegate:self];
  window_ = [[NSWindow alloc] initWithContentRect:rect 
                                        styleMask:0 
                                          backing:NSBackingStoreBuffered 
                                            defer:YES];
  [window_ setContentView:view_];
  NSURL* url = [NSURL URLWithString:@"file:///Users/kelsey/Desktop/chromeless_example_1.html"];
  NSURLRequest* request = [NSURLRequest requestWithURL:url];
  [[view_ mainFrame] loadRequest:request];
  NSLog(@"load done");
}

// <WebFrameLoadDelegate> callback once the video loads
- (void)webView:(WebView*)view didFinishLoadForFrame:(WebFrame*)frame
{
  NSLog(@"did finish loading");
  if( frame != [view mainFrame] ) return;
  [window_ display];
  [window_ orderFrontRegardless];
}

- (void)close
{
  [view_ close];
  view_ = nil;
  [window_ close];
  window_ = nil;
}

- (void)playPause
{
}

- (void)skipForward
{
}

- (void)skipBackward
{
}

@end
