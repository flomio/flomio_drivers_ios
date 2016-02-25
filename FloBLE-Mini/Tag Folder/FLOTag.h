//
//  FLOTag.h
//  
//
//  Created by John Bullard on 9/21/12.
//  Copyright (c) 2012 Flomio Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NFCMessage.h"
#import "NDEFMessage.h"
#import "NDEFRecord.h"
#import "Logging.h"

#define FLOMIO_TAG_MAX_DATA_LEN             168
#define FLOMIO_TAG_MAX_PAGES                42
#define FLOMIO_TAG_MAX_UID_LEN              8
#define NFC_FORUM_TYPE2_CC_LOC              13

@interface FJNFCTag : NSObject

@property(nonatomic, readonly) NSData *uid;
@property(nonatomic, readonly) int  nfcForumType;
@property(nonatomic, readonly) NSData *data;
@property(nonatomic, readonly) NDEFMessage *ndefMessage;

- (id)initWithUid:(NSData *)theUid;
- (id)initWithUid:(NSData *)theUid andData:(NSData *)theData;
- (id)initWithUid:(NSData *)theUid andData:(NSData *)theData andType:(UInt8)type;

// Methods for parsing NFC Forum Type 2 memory.
- (NDEFMessage *)parseMemoryForNdefMessage;
- (NDEFMessage *)type2ParseMemoryForNdefMessage;
- (UInt8)type2ParseMemoryForNdefTLVLocation;

@end
