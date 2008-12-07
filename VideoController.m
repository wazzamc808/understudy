//
//  VideoController.m
//  Understudy FR Appliance
//
//  Created by Kirk Kelsey.
//  Copyright 2008. All rights reserved.
//

#include <regex.h>

#import "VideoController.h"

#import <BackRow/BRControllerStack.h>
#import <BackRow/BRDisplayManager.h>
#import <BackRow/BREvent.h>
#import <BackRow/BRRenderScene.h>
#import <BackRow/BRSentinel.h>

#import <Carbon/Carbon.h>

@interface BRAppManager : NSObject { }
+ (BRAppManager*)sharedApplication;
- (id)delegate;
@end

@protocol  BRAppManagerDelegate
- (void)_continueDestroyScene:id;
@end

@interface BRRenderer{}
- (void)orderIn;
- (void)orderOut;
@end

@interface VideoController (private)
- (void)_loadVideo;
- (void)_maximizePlayer;
- (void)_fullscreen;
- (void)_reveal;
- (void)_returnToFR;
- (void)_sendKeyPress: (int)keyCode;
@end

@implementation VideoController

- (id)initWithVideoAsset:(VideoAsset*)asset
{
  [super init];
  asset_ = [asset retain];
  return self;
}

- (void)dealloc
{
  [asset_ release];
  [super dealloc];
}

- (void)_loadVideo
{
  // invoking shared application ensures that windows can be ordered
  [NSApplication sharedApplication];
  NSRect rect = [[NSScreen mainScreen] frame];
  view_ = [[[WebView alloc] initWithFrame:rect] retain];
  [[[view_ mainFrame] frameView] setAllowsScrolling:NO];
  [view_ setFrameLoadDelegate:self];
  window_ = [[[NSWindow alloc] initWithContentRect:rect 
                                         styleMask:0 
                                           backing:NSBackingStoreBuffered 
                                             defer:YES] retain];
  [window_ setContentView:view_];
  NSURLRequest* pageRequest = [NSURLRequest requestWithURL:[asset_ url]];
  [[view_ mainFrame] loadRequest:pageRequest];
}

// <WebFrameLoadDelegate> callback once the video loads
- (void)webView:(WebView*)view didFinishLoadForFrame:(WebFrame*)frame
{
  if( [view isInFullScreenMode] ) return;
  [self _maximizePlayer];
  [self _fullscreen];
  [self _reveal];
}

- (void)_maximizePlayer
{
  WebScriptObject* script = [view_ windowScriptObject];
  id p = [script evaluateWebScript:@"document.player.nodeName"];
  NSString* player = p;
  if( !player || [player length] == 0 ) return;
  NSSize size = [view_ frame].size;
  NSString* width = [NSString stringWithFormat:@"%1.0f",size.width,nil];
  NSString* height = [NSString stringWithFormat:@"%1.0f",size.height,nil];
  [script evaluateWebScript:@"d = document.getElementsByTagName('div'); var i = 0; for( i = 0; i < d.length; i++ ){ d[i].setAttribute('style','display: none');}"];
  NSString* flashvars = [script evaluateWebScript:@"document.player.getAttribute('flashvars')"];
  const char* cText = [flashvars cStringUsingEncoding:[NSString defaultCStringEncoding]];
  int nmatch = 2;
  regex_t regex;
  regmatch_t pmatch[nmatch];
  regcomp(&regex,"stage_height=([[:digit:]]+)",REG_EXTENDED);
  int res = regexec(&regex, cText, nmatch, pmatch, 0);
  if( res != 0 || pmatch[nmatch - 1].rm_so == -1 ){
    NSLog(@"failed to find stage height");
    return;
  }
  NSRange range = {pmatch[1].rm_so, pmatch[1].rm_eo-pmatch[1].rm_so};
  flashvars = [flashvars stringByReplacingCharactersInRange:range 
                                                 withString:height];
  regcomp(&regex,"stage_width=([[:digit:]]+)",REG_EXTENDED);
  res = regexec(&regex, cText, nmatch, pmatch, 0);
  if( res != 0 || pmatch[nmatch - 1].rm_so == -1 ){
    NSLog(@"failed to find stage width");
    return;
  }
  range.location = pmatch[1].rm_so;
  range.length = pmatch[1].rm_eo-pmatch[1].rm_so;
  flashvars = [flashvars stringByReplacingCharactersInRange:range 
                                                 withString:width];
  regfree(&regex);
  NSString* format = [NSString stringWithString:@"var p = document.player; var horig=p.getAttribute('height'); var worig=p.getAttribute('width'); var height=%@; var width=%@; var wflash=2*width-worig; var hflash=2*height-horig; var woffset=(wflash-worig)/2; var hoffset=(hflash-horig)/2; p.setAttribute('flashvars','%@'); p.setAttribute('style','display: none'); var t = p.parentNode; while(t!=document.body.parentNode){ t.setAttribute('style',\"position:absolute; text-align: left; display: block;\"); t.setAttribute(\"height\",height); t.setAttribute(\"width\",width); t = t.parentNode }; p.setAttribute(\"height\",hflash+\"px\"); p.setAttribute(\"width\",wflash+\"px\"); p.setAttribute(\"style\",\"display: normal; z-index: 10; position: absolute; top:-\"+hoffset+\"px; left:-\"+woffset+\"px;\");"];
  NSString* resize = [NSString stringWithFormat:format, height, width, flashvars, nil];
  [script evaluateWebScript:resize];
  [view_ setNeedsDisplay:YES];
}

// make the WebView fullscreen
- (void)_fullscreen
{
  BRDisplayManager* manager = [BRDisplayManager sharedInstance];
  NSDictionary* mode = [manager displayMode];
  NSArray* objects = [NSArray arrayWithObjects: NSFullScreenModeAllScreens,
                      NSFullScreenModeWindowLevel,
                      NSFullScreenModeSetting,
                      nil ];
  NSArray* keys = [NSArray arrayWithObjects: [NSNumber numberWithBool:YES],
                   [NSNumber numberWithInt:14],
                   mode,
                   nil ];
  NSDictionary* options = [NSDictionary dictionaryWithObjects:objects
                                                      forKeys:keys];
  [view_ enterFullScreenMode:[NSScreen mainScreen]
                 withOptions:options];
  [self _sendKeyPress:3];
}

// order out the FR window, revealing the video display
- (void)_reveal
{
  BRSentinel* sentinel = [BRSentinel sharedInstance];
  id<BRRendererProvider> provider = [sentinel rendererProvider];
  BRRenderer* renderer = [provider renderer];
  [renderer orderOut];
}

// un-fullscreen the hulu video and bring back the FR display
- (void) _returnToFR
{
  [view_ exitFullScreenModeWithOptions:nil];
  [window_ close];
  [view_ close];
  window_ = nil;
  view_ = nil;
  BRSentinel* sentinel = [BRSentinel sharedInstance];
  id<BRRendererProvider> provider = [sentinel rendererProvider];
  BRRenderer* renderer = [provider renderer];
  [renderer orderIn];  
}

// grab the web view for the flash player
- (WebView*)_pluginView
{
  if( !pluginView_ )
  {
    NSMutableSet* views = [NSMutableSet set];
    NSMutableSet* webviews = [NSMutableSet set];
    [views addObjectsFromArray:[view_ subviews]];
    while( [views count] ){
      WebView* view = [views anyObject];
      [views removeObject:view];
      if( [[view className] isEqual:@"WebNetscapePluginDocumentView"] )
        [webviews addObject:view];
      [views addObjectsFromArray:[view subviews]];
    }
    if( [webviews count] > 1 ) NSLog(@"got multiple plugin views");
    else if( [webviews count] < 1 ) NSLog(@"got no plugin views");
    pluginView_ = [webviews anyObject];
  }
  return pluginView_;
}

// Send a keydown (and up) event to the web view holding the flash plugin
// (using NSEvent doesn't work)
- (void)_sendKeyPress:(int)keyCode
{
  WebView* view = [self _pluginView];
  EventRecord event; 
  event.what = keyDown; 
  event.message = keyCode << 8; 
  event.modifiers = 0;   
  [(id)view sendEvent:(NSEvent *)&event];
  event.what = keyUp;
  [(id)view sendEvent:(NSEvent *)&event];
}

- (void)playPause
{
  [self _sendKeyPress:49]; // space-bar
}

#pragma mark BR Control

- (void)controlWillActivate
{
  [super controlWillActivate];
  [self _loadVideo];
}

- (void)controlWillDeactivate
{
  [super controlWillDeactivate];
  [self _returnToFR];
}

- (BOOL)isNetworkDependent
{
  return YES;
}

- (BOOL)brEventAction:(BREvent*)event
{
  if( [event remoteAction] == kBRRemotePlayPauseSelectButton )
  {
    [self playPause];
    return YES;
  }
  return [super brEventAction:event];
}

@end
