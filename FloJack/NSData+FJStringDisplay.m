//
//  NSData+FJNFCAdditions.m
//  FloJack
//
//  Created by John Bullard on 9/21/12.
//  Copyright (c) 2012 Flomio Inc. All rights reserved.
//

#import "NSData+FJStringDisplay.h"

@implementation NSData (FJStringDisplay)

- (NSString *)fj_asHexString;
{
    NSMutableString *result = [NSMutableString string];
    const unsigned char *bytes = (const unsigned char*) [self bytes];
    for (int i = 0; i < [self length]; i++)
    {
        [result appendFormat:@"0x%02hhx ", (unsigned char) bytes[i]];
    }
    return result;
}


@end
