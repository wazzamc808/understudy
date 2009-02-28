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

#import <stdint.h>

#import "UNDPreferenceManager.h"
#import "YouTubeController.h"
#import "YouTubeAsset.h"

@implementation YouTubeController

- (id)initWithAsset:(YouTubeAsset*)asset
{
  [super init];
  asset_ = [asset retain];
  return self;
}

#define EMBED_URL @"http://youtube.com/apiplayer?enablejsapi=1&fs=1"

- (void)load
{
  [NSApplication sharedApplication];
  NSRect rect = [[UNDPreferenceManager screen] frame];
  view_ = [[WebView alloc] initWithFrame:rect];
  [[[view_ mainFrame] frameView] setAllowsScrolling:NO];
  [view_ setFrameLoadDelegate:self];
  [view_ setResourceLoadDelegate:self];
  window_ = [[NSWindow alloc] initWithContentRect:rect 
                                        styleMask:0 
                                          backing:NSBackingStoreBuffered 
                                            defer:YES];
  [window_ setContentView:view_];
  NSURL* url = [NSURL URLWithString:EMBED_URL];
  NSURLRequest* request = [NSURLRequest requestWithURL:url];
  [[view_ mainFrame] loadRequest:request];
}


- (id)_playerFunction:(NSString*)func{
  NSString* call;
  WebScriptObject* script = [[[view_ windowScriptObject] retain] autorelease];
  
  call = @"document.getElementsByTagName('EMBED')[0].";
  call = [call stringByAppendingString:func];
  return [script evaluateWebScript:call];
}

// Instruct the page to actually load the video. This will fail if the flash
// player has had a chance to fully load, so cannot be invoked from the webview
// notification routines (but does work based on later user input).
- (BOOL)enqueueVideo
{ 
  id result;
  
  
  NSString* load = @"loadVideoById('%@',0)";
  load = [NSString stringWithFormat:load, [asset_ videoID]];
  [self _playerFunction:load];
  
  // if there is a video URL, then the video is loading (or loaded)
  result = [self _playerFunction:@"getVideoUrl()"];
  return ( result != nil );
}

- (void)attemptEnqueue
{
  sleep(1);
  [self performSelectorOnMainThread:@selector(enqueueVideo)
                         withObject:nil
                      waitUntilDone:YES];
}

// <WebFrameLoadDelegate> callback once the video loads
- (void)webView:(WebView*)view didFinishLoadForFrame:(WebFrame*)frame
{
  NSLog(@"did finish loading");
  if( frame != [view mainFrame] ) return;
  [window_ display];
  [window_ orderFrontRegardless];
  [window_ setLevel:CGShieldingWindowLevel()];
  [self reveal];
  [self performSelectorInBackground:@selector(attemptEnqueue) withObject:nil];
}

- (void)controlWillActivate
{
  [self load];
}

- (void)controlWillDeactivate
{
  [self returnToFR];
  [view_ close];
  view_ = nil;
  [window_ close];
  window_ = nil;
}

- (void)fastForward
{
  [self enqueueVideo];
}

@end
