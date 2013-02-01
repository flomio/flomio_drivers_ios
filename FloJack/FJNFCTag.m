//
//  FJNFCTag.m
//  FloJack
//
//  Created by John Bullard on 9/21/12.
//  Copyright (c) 2012 Flomio Inc. All rights reserved.
//

#import "FJNFCTag.h"

@implementation FJNFCTag {
    NSData      *_uid;
    NSData      *_data;    
}

@synthesize uid = _uid;
@synthesize data = _data;
@synthesize ndefMessage = _ndefMessage;


// Designated initializer
- (id)initWithUid:(NSData *)theUid andData:(NSData *)theData; {
    self = [super init];
    if(self) {
        _uid = [theUid copy];
        _data = [theData copy];
        
        //NSArray *ndefRecords = [FJNDEFRecord parseData:_data andIgnoreMbMe:FALSE];
        //_ndefMessage = [[FJNDEFMessage alloc] initWithNdefRecords:ndefRecords];
        
    }
    return self;
}

- (id)initWithUid:(NSData *)theUid;{
    return [self initWithUid:theUid andData:nil];
}

@end
