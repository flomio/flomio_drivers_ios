//
//  FJNFCTag.h
//  FloJack
//
//  Created by John Bullard on 9/21/12.
//  Copyright (c) 2012 Flomio Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FJNDEFMessage.h"
#import "FJNDEFRecord.h"

typedef enum
{
    NFC_FORUM_TYPE_1 = 1,
    NFC_FORUM_TYPE_2,
    NFC_FORUM_TYPE_3,
    NFC_FORUM_TYPE_4
} nfc_forum_types_t;

@interface FJNFCTag : NSObject

@property(nonatomic, readonly) NSData *uid;
@property(nonatomic, readonly) int  nfcForumType;
@property(nonatomic, readonly) NSData *data;
@property(nonatomic, readonly) FJNDEFMessage *ndefMessage;

- (id)initWithUid:(NSData *)theUid;
- (id)initWithUid:(NSData *)theUid andData:(NSData *)theData;


/*
 Collection of static methods for parsing NFC Forum Type 2 memory.
 
 --READ--
 -dynamic vs static memory
 -r/w security
 -cc bytes
 -NDEF Message(s)
 -counters
 
 This will parse out Lock, Memory, NDEF, and other TLV headers.
 
 
 --WRITE--
 TODO
 
 */
#define NFC_FORUM_TYPE2_CC_LOC              13;

- (FJNDEFMessage *)parseMemoryForNdefMessage;
- (FJNDEFMessage *)type2ParseMemoryForNdefMessage;

@end
