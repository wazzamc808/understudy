/*
 *     Generated by class-dump 3.1.2.
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2007 by Steve Nygard.
 */

/// \addtogroup BackRow

/// \ingroup BackRow
@interface BREvent : NSObject
{
    int _action;
    unsigned short _page;
    unsigned short _usage;
    int _value;
    BOOL _retrigger;
    double _timeStamp;
}

- (id)initWithPage:(unsigned short)fp8 usage:(unsigned short)fp12 value:(int)fp16;
- (id)initWithPage:(unsigned short)fp8 usage:(unsigned short)fp12 value:(int)fp16 atTime:(double)fp20;
- (id)description;
- (BOOL)isEqual:(id)fp8;
- (int)remoteAction;
- (unsigned int)pageUsageHash;
- (unsigned short)page;
- (unsigned short)usage;
- (int)value;
- (BOOL)retriggerEvent;
- (void)makeRetriggerEvent;
- (double)timeStamp;

@end

