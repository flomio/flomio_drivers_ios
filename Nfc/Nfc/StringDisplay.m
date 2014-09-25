//
//  StringDisplay.m
//  Flomio
//
//  Created by John Bullard on 9/21/12.
//  Copyright (c) 2012 Flomio Inc. All rights reserved.
//

#import "StringDisplay.h"

@implementation NSData (StringDisplay)

- (NSString *)fj_asHexString;
{
    NSMutableString *result = [NSMutableString string];
    [result appendFormat:@"0x"];
    
    const unsigned char *bytes = (const unsigned char*) [self bytes];
    for (int i = 0; i < [self length]; i++)
    {
        [result appendFormat:@"%02hhx", (unsigned char) bytes[i]];
    }
    return result;
}

- (NSString *)fj_asHexStringWithSpace;
{
    NSMutableString *result = [NSMutableString string];
    const unsigned char *bytes = (const unsigned char*) [self bytes];
    for (int i = 0; i < [self length]; i++)
    {
        [result appendFormat:@"0x%02hhx ", (unsigned char) bytes[i]];
    }
    return result;
}

- (NSString *)fj_asHexWordStringWithSpace;
{
    NSMutableString *result = [NSMutableString string];
    const unsigned char *bytes = (const unsigned char*) [self bytes];
    for (int i = 0; i < [self length]; i+=2)
    {
        [result appendFormat:@"0x%02hhx%02hhx ", (unsigned char) bytes[i], (unsigned char) bytes[i+1]];
    }
    return result;
}

- (NSString *)fj_asASCIIStringEncoded;
{
    return [[NSString alloc] initWithData:self encoding:NSASCIIStringEncoding];
}

@end
