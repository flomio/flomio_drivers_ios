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

@interface FJNFCTag : NSObject

@property(nonatomic, readonly) NSData *uid;
@property(nonatomic, readonly) NSData *data;
@property(nonatomic, readonly) FJNDEFMessage *ndefMessage;

- (id)initWithUid:(NSData *)theUid;
- (id)initWithUid:(NSData *)theUid andData:(NSData *)theData; 

@end
