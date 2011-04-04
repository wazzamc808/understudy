/*
 *     Generated by class-dump 3.1.2.
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2007 by Steve Nygard.
 */

#import <Foundation/Foundation.h>

@class NSMutableArray;

/// \addtogroup BackRow

/// \ingroup BackRow
@interface BRURLDocumentManager : NSObject
{
    NSMutableArray *_highPriorityDocuments;
    NSMutableArray *_lowPriorityDocuments;
    NSMutableArray *_activeDocuments;
    unsigned int _maximumActiveDocuments;
    BOOL _loadDocuments;
}

+ (id)textDocumentManager;
+ (id)imageDocumentManager;
- (id)init;
- (void)dealloc;
- (void)invalidate;
- (void)purgeDocuments;
- (void)setMaximumActiveDocuments:(unsigned int)fp8;
- (unsigned int)maximumActiveDocuments;
- (void)loadDocument:(id)fp8;
- (void)loadDocument:(id)fp8 withPriority:(int)fp12;
- (void)cancelLoad:(id)fp8;

@end
