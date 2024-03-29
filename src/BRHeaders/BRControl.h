/*
 *     Generated by class-dump 3.1.2.
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2007 by Steve Nygard.
 */

#import <Foundation/Foundation.h>
#import "BREventResponder-Protocol.h"

@class BRLayer;

/// \addtogroup BackRow

/// \ingroup BackRow
@interface BRControl : NSObject <BREventResponder>
{
    id _parent;
    BOOL _controlActive;
    BRLayer *_defaultLayer;
}

+ (id)control;
+ (id)controlWithBackingLayer:(id)fp8;
- (id)init;
- (id)initWithBackingLayer:(id)fp8;
- (void)dealloc;
- (void)setParent:(id)fp8;
- (id)parent;
- (BOOL)active;
- (void)controlWillActivate;
- (void)controlWasActivated;
- (void)controlWillDeactivate;
- (void)controlWasDeactivated;
- (id)layer;
- (BOOL)brEventAction:(id)fp8;
- (void)setFrame:(struct CGRect)fp8;
- (struct CGRect)frame;
- (void)setName:(id)fp8;
- (id)name;
- (void)setHidden:(BOOL)fp8;
- (BOOL)isHidden;
- (void)setActions:(id)fp8;
- (id)actions;
- (void)setAutoresizingMask:(unsigned int)fp8;
- (unsigned int)autoresizingMask;

@end

