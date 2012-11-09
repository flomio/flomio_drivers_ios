//
//  FJNFCTag.h
//  FloJack
//
//  Created by John Bullard on 9/21/12.
//  Copyright (c) 2012 Flomio Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FJNFCTag : NSObject

@property(nonatomic, readonly) NSData *uid;

- (id)initWithUid:(NSData *)theUid;

@end
