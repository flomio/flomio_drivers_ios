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
    
}

@synthesize uid = _uid;


/*!
 Custom constructor which returns Tag object with given UID
 
 @param uidInit The tag UUID
 
 */
- (id)initWithUid:(NSData *)theUid;{
    self = [super init];
    if(self) {        
        _uid = [theUid copy];
    }
    return self;
}


@end
