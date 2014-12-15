//
//  NSData+FJNFCAdditions.h
//  
//
//  Created by John Bullard on 9/21/12.
//  Copyright (c) 2012 Flomio Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (FJStringDisplay)

- (NSString *)fj_asHexString;
- (NSString *)fj_asHexStringWithSpace;
- (NSString *)fj_asHexWordStringWithSpace;
- (NSString *)fj_asASCIIStringEncoded;

@end
