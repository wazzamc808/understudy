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

#include <regex.h>

#import "HuluController.h"

#import <BackRow/BRControllerStack.h>
#import <BackRow/BRDisplayManager.h>
#import <BackRow/BREvent.h>
#import <BackRow/BRRenderScene.h>
#import <BackRow/BRSentinel.h>
#import <BackRow/BRSettingsFacade.h>

#import <Carbon/Carbon.h>

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
  view_ = [[WebView alloc] initWithFrame:rect];
  [[[view_ mainFrame] frameView] setAllowsScrolling:NO];
  [view_ setFrameLoadDelegate:self];
  window_ = [[NSWindow alloc] initWithContentRect:rect 
                                        styleMask:0 
                                          backing:NSBackingStoreBuffered 
                                            defer:YES];
  [window_ setContentView:view_];
  NSURLRequest* pageRequest = [NSURLRequest requestWithURL:[asset_ url]];
  [[view_ mainFrame] loadRequest:pageRequest];
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
  id player = [script evaluateWebScript:@"document.player.nodeName"];
  if( player == [WebUndefined undefined]){
    pluginView_ = view_;
    return;
  }
  
  // javascript statements (invoked near the end of this method)
  NSString* getFlashVars = @"document.player.getAttribute('flashvars')";
  NSString* getHeight = @"document.player.getAttribute('height');";
  NSString* getWidth = @"document.player.getAttribute('width');";
  NSString* hidedivs=@"d = document.getElementsByTagName('div'); var i=0; for("\
  "i = 0; i < d.length; i++ ){ d[i].setAttribute('style','display:none'); }";
  NSString* setflashvars=@"document.player.setAttribute('flashvars','%@');";
  NSString* hideplayer=@"document.player.setAttribute('style','display:none');";
  NSString* setstyle = @"document.player.setAttribute('style','display:normal;"\
  " position:absolute; top:%4.0fpx; left:%4.0fpx;'); document.body.setAttrib"\
  "ute('style','background:rgb(40,39,39)')";
  NSString* movedivs = @"var t = document.player; while( t!=document.body.pare"\
  "ntNode ){ t.setAttribute('style','position:absolute; text-align: left; disp"\
  "lay:block;'); t.setAttribute('height',%4.0f); t.setAttribute('width'"\
  ",%4.0f); t = t.parentNode };";  
  
  NSSize screen = [view_ frame].size;
  NSSize oldstage; // original stage (and dom element) size
  NSSize oldview;  // original viewable size (stage less buttons)
  NSSize newview;  // desired new viewable size
  NSSize newstage; // new declared stage size
  NSSize padding;  // extra space introduced to keep player centered
  NSSize newsize;  // newstage + padding

  oldstage.height = [[script evaluateWebScript:getHeight] floatValue];
  oldstage.width = [[script evaluateWebScript:getWidth] floatValue];
  oldview.height = oldstage.height - 8; // taken by the progress bar
  oldview.width = oldstage.width - 150; // taken by the stage buttons 
  newview = screen;
  if( oldview.height / screen.height > oldview.width  / screen.width )
  {
    newview.height = screen.height;
    newview.width = (oldview.width / oldview.height) * newview.height;
  }else{
    newview.width = screen.width;
    newview.height = (oldview.height / oldview.width) * newview.width;    
  }
  newstage.width = newview.width + 150;
  newstage.height = newview.height + 8;
  
  // the flash player determines how large the video should be from an attribute
  // of the html embed object named flashvars. the stage_height and stage_width
  // are related to, but not the same as the html entity's height and width
  NSMutableString* flashvars;
  flashvars = [[script evaluateWebScript:getFlashVars] mutableCopy];
  replaceDimension("stage_height",flashvars,(int)newview.height);
  // we let the player determine it's own width (since the aspect ratio of the
  // player isn't the same as the video)
  
  // we size the container to fit the new viewable area and padding that is
  // added (for every pixel we add to the stage size, a pixel is added).
  newsize.height = 2 * newview.height - oldstage.height;
  newsize.width = 2 * newview.width - oldstage.width;
  
  // the flash player adds padding to keep itself centered in it's container.
  // we don't have to worry about the buttons as long as the newview > oldstage
  padding.width = (newview.width - newsize.width) / 2;
  padding.height = (oldstage.height - newsize.height) / 2;
  // the padding below the player is this less delta(stagesize)
  
  // in addition to the player's own padding, we may have introduced some by
  // maintaining the player's aspect ratio. we offset that here
  padding.height -= (newview.height - screen.height) / 2;
  padding.width -= (newview.width - screen.width) /2;
  
  setflashvars = [NSString stringWithFormat:setflashvars,flashvars];
  movedivs = [NSString stringWithFormat:movedivs,newsize.height,newsize.width];
  setstyle = [NSString stringWithFormat:setstyle,padding.height,padding.width];

  // hide all of the <div> elements (get rid of other content)
  [script evaluateWebScript:hidedivs];
  // update the flashvars (stage width and height)
  [script evaluateWebScript:setflashvars];
  // move the player (and it's ancestors) top/left
  [script evaluateWebScript:movedivs];
  [script evaluateWebScript:hideplayer];
  // show the player, offset it, and make the body background gray
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

// <WebFrameLoadDelegate> callback once the video loads
- (void)webView:(WebView*)view didFinishLoadForFrame:(WebFrame*)frame
{
  if( frame != [view mainFrame] ) return;
  [self _maximizePlayer];
  [window_ display];
  [window_ orderFrontRegardless];
  [self _fullscreen];
  [self reveal];
}

- (void)playPause
{
  [[self _pluginView] sendKeyCode:49 withCharCode:0]; // space-bar
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
  [self returnToFR];
  [view_ exitFullScreenModeWithOptions:nil];
  [window_ close];
  [view_ close];
  window_ = nil;
  view_ = nil;
}

@end
