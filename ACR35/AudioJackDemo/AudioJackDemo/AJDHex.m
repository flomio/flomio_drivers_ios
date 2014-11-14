/*
 * Copyright (C) 2014 Advanced Card Systems Ltd. All Rights Reserved.
 *
 * This software is the confidential and proprietary information of Advanced
 * Card Systems Ltd. ("Confidential Information").  You shall not disclose such
 * Confidential Information and shall use it only in accordance with the terms
 * of the license agreement you entered into with ACS.
 */

#import "AJDHex.h"

@implementation AJDHex

+ (NSString *)hexStringFromByteArray:(const uint8_t *)buffer length:(NSUInteger)length {

    NSString *hexString = @"";
    NSUInteger i = 0;

    for (i = 0; i < length; i++) {
        if (i == 0) {
            hexString = [hexString stringByAppendingFormat:@"%02X", buffer[i]];
        } else {
            hexString = [hexString stringByAppendingFormat:@" %02X", buffer[i]];
        }
    }

    return hexString;
}

+ (NSString *)hexStringFromByteArray:(NSData *)buffer {
    return [self hexStringFromByteArray:[buffer bytes] length:[buffer length]];
}

+ (NSData *)byteArrayFromHexString:(NSString *)hexString {

    NSData *byteArray = nil;
    uint8_t *buffer = NULL;
    NSUInteger i = 0;
    unichar c = 0;
    NSUInteger count = 0;
    int num = 0;
    BOOL first = YES;
    NSUInteger length = 0;

    // Count the number of HEX characters.
    for (i = 0; i < [hexString length]; i++) {

        c = [hexString characterAtIndex:i];
        if (((c >= '0') && (c <= '9')) ||
            ((c >= 'A') && (c <= 'F')) ||
            ((c >= 'a') && (c <= 'f'))) {
            count++;
        }
    }

    // Allocate the buffer.
    buffer = (uint8_t *) malloc((count + 1) / 2);
    if (buffer != NULL) {

        for (i = 0; i < [hexString length]; i++) {

            c = [hexString characterAtIndex:i];
            if ((c >= '0') && (c <= '9')) {
                num = c - '0';
            } else if ((c >= 'A') && (c <= 'F')) {
                num = c - 'A' + 10;
            } else if ((c >= 'a') && (c <= 'f')) {
                num = c - 'a' + 10;
            } else {
                num = -1;
            }

            if (num >= 0) {

                if (first) {

                    buffer[length] = num << 4;

                } else {

                    buffer[length] |= num;
                    length++;
                }

                first = !first;
            }
        }

        // Create the byte array.
        byteArray = [NSData dataWithBytesNoCopy:buffer length:length];
    }
    
    return byteArray;
}

@end
