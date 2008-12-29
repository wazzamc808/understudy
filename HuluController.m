//
//  Copyright 2008 Kirk Kelsey.
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

#include <regex.h>

#import "HuluController.h"

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

@interface HuluController (private)
- (void)_loadVideo;
- (void)_maximizePlayer;
- (void)_reveal;
- (void)_returnToFR;
- (void)_sendKeyCode:(int)keyCode withCharCode:(int)charCode;
- (void)_fullscreen;
@end

@implementation HuluController

- (id)initWithAsset:(HuluAsset*)asset
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
  if( frame != [view mainFrame] ) return;
  [self _maximizePlayer];
  [window_ display];
  [window_ orderFrontRegardless];
  [self _fullscreen];
  [self _reveal];
}

// replace in |string| the numeric value after |name|= with |newdim|
BOOL replaceDimension (const char* name, NSMutableString* string, int newdim)
{
  int nmatch = 2, res;
  regex_t regex;
  regmatch_t pmatch[nmatch];
  NSString *regstr;
  const char *regtext, *sourcetext;
  
  regstr = [NSString stringWithFormat:@"%s=([[:digit:]]+)",name];
  regtext = [regstr cStringUsingEncoding:[NSString defaultCStringEncoding]];
  sourcetext = [string cStringUsingEncoding:[NSString defaultCStringEncoding]];
  
  regcomp(&regex, regtext, REG_EXTENDED);
  res = regexec(&regex, sourcetext, nmatch, pmatch, 0);
  
  if( res != 0 || pmatch[nmatch - 1].rm_so == -1 ) return NO;
  NSRange range = {pmatch[1].rm_so, pmatch[1].rm_eo-pmatch[1].rm_so};
  [string replaceCharactersInRange:range 
                        withString:[NSString stringWithFormat:@"%d",newdim]];
  regfree(&regex);
  return YES;
}

// manipulate the web page DOM so that the player fills the screen
- (void)_maximizePlayer
{
  // be sure we can get ahold of the flash player
  WebScriptObject* script = [view_ windowScriptObject];
  NSString* player;
  player = (NSString*) [script evaluateWebScript:@"document.player.nodeName"];
  if( !player || [player length] == 0 ) return;

  NSString* movedivs;
  NSString* getFlashVars = @"document.player.getAttribute('flashvars')";
  NSString* getHeight = @"document.player.getAttribute('height');";
  NSString* getWidth = @"document.player.getAttribute('width');";
  NSString* hidedivs=@"d = document.getElementsByTagName('div'); var i=0; for( i = 0;"\
  " i < d.length; i++ ){ d[i].setAttribute('style','display:none'); }";
  NSString* setflashvars=@"document.player.setAttribute('flashvars','%@');";
  NSString* hideplayer = @"document.player.setAttribute('style','display: none');";
  NSString* setheight = @"document.player.setAttribute('height','%dpx');";
  NSString* setwidth = @"document.player.setAttribute('width','%dpx');";
  NSString* setstyle = @"document.player.setAttribute('style','display:normal;"\
  " position:absolute; top:-%dpx; left:-%dpx;'); document.body.setAttribute('s"\
  "tyle','background:rgb(40,39,39)')";
  movedivs = @"var t = document.player.parentNode; while( t!=document.body.parentNode )"\
  "{ t.setAttribute('style','position:absolute; text-align:left; display:block;')"\
  "; t.setAttribute('height',%d); t.setAttribute('width',%d); t = t.parentNode };";
  
  NSSize screen = [view_ frame].size;
  int pHeight = [[script evaluateWebScript:getHeight] intValue];
  int pWidth = [[script evaluateWebScript:getWidth] intValue];
  int newheight = screen.height;
  int newwidth = screen.width;

  // the flash player determines how large the video should be from an attribute
  // of the html embed object named flashvars. the stage_height and stage_width
  // are related to, but not the same as the html entity's height and width
  NSMutableString* flashvars;
  flashvars = [[script evaluateWebScript:getFlashVars] mutableCopy];
  replaceDimension("stage_height",flashvars,newheight);
  replaceDimension("stage_width",flashvars,newheight);
  
  // When the stage size is increased, space is padded around the actual video.
  // Since some of the extra space is wasted, the new size is extended and the
  // stage is offset to remove the padding
  int hflash = (2*newheight)-pHeight;
  int wflash = (2*newwidth)-pWidth;
  int hoffset = (int)((hflash - pHeight)/2);  // 2 and 
  int woffset = (int)((wflash - pWidth)/4);   // 4 are empirical
  // If the player isn't filling the screen then we'll recenter it
  hoffset -= (screen.height-newheight)/2;
  woffset -= (screen.width-newwidth);
  
  setflashvars = [NSString stringWithFormat:setflashvars,flashvars];
  movedivs = [NSString stringWithFormat:movedivs,newheight,newwidth];
  setwidth = [NSString stringWithFormat:setwidth,wflash];
  setheight = [NSString stringWithFormat:setheight,hflash];
  setstyle = [NSString stringWithFormat:setstyle,hoffset,woffset];

  // hide all of the <div> elements - get rid of other content
  [script evaluateWebScript:hidedivs];
  // update the flashvars (stage width and height)
  [script evaluateWebScript:setflashvars];
  // move the player (and it's ancestors) top/left
  [script evaluateWebScript:movedivs];
  [script evaluateWebScript:hideplayer];
  // set the width (and height) of the player object
  [script evaluateWebScript:setwidth];
  [script evaluateWebScript:setheight];
  // show the player (offset)  make the body background gray
  [script evaluateWebScript:setstyle];
    
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
}

// order out the FR window, revealing the video display
- (void)_reveal
{
  BRSentinel* sentinel = [BRSentinel sharedInstance];
  id<BRRendererProvider> provider = [sentinel rendererProvider];
  BRRenderer* renderer = [provider renderer];
  [renderer orderOut];
}

// bring back the FR display, unshield the menu, close the player
- (void) _returnToFR
{
  BRSentinel* sentinel = [BRSentinel sharedInstance];
  id<BRRendererProvider> provider = [sentinel rendererProvider];
  BRRenderer* renderer = [provider renderer];
  [renderer orderIn];  
  [view_ exitFullScreenModeWithOptions:nil];
  [window_ close];
  [view_ close];
  window_ = nil;
  view_ = nil;
}

// grab the web view for the flash player
- (WebView*)_pluginView
{
  if( !pluginView_ )
  {
    NSMutableSet* views = [[[NSMutableSet set] retain] autorelease];
    NSMutableSet* webviews = [[[NSMutableSet set] retain] autorelease];
    [views addObjectsFromArray:[view_ subviews]];
    while( [views count] ){
      WebView* view = [views anyObject];
      if( [[view className] isEqual:@"WebNetscapePluginDocumentView"] )
        [webviews addObject:view];
      [views addObjectsFromArray:[view subviews]];
      [views removeObject:view];
    }
    if( [webviews count] < 1 ) NSLog(@"got no plugin views");
    else
    {
      if( [webviews count] > 1 ) NSLog(@"got multiple plugin views");
      pluginView_ = [webviews anyObject];
      [pluginView_ retain];
    }
  }
  return pluginView_;
}

// Send a keydown (and up) event to the web view holding the flash plugin
// (using NSEvent doesn't work)
- (void)_sendKeyCode:(int)keyCode withCharCode:(int)charCode;
{
  WebView* view = [self _pluginView];
  EventRecord event; 
  event.what = keyDown; 
  event.message = (keyCode << 8) + charCode;
  event.modifiers = 0;
  [(id)view sendEvent:(NSEvent *)&event];
  event.what = keyUp;
  [(id)view sendEvent:(NSEvent *)&event];
  [view autorelease];
}

- (void)playPause
{
  [self _sendKeyCode:49 withCharCode:0]; // space-bar
}

- (void)_flashFullscreen
{
  [self _sendKeyCode:3 withCharCode:102]; // 'f'
}

- (void)_flashExitFullscreen
{
  [self _sendKeyCode:53 withCharCode:27]; // ESC
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

// play/pause works as expected, anythings else will fullscren the flash player
- (BOOL)brEventAction:(BREvent*)event
{
  if( [event remoteAction] == kBRRemotePlayPauseSelectButton )
  {
    [self playPause];
    return YES;
  }
  [self _flashFullscreen];
  return [super brEventAction:event];
}

@end
