/*
 * Copyright (C) 2014 Advanced Card Systems Ltd. All Rights Reserved.
 *
 * This software is the confidential and proprietary information of Advanced
 * Card Systems Ltd. ("Confidential Information").  You shall not disclose such
 * Confidential Information and shall use it only in accordance with the terms
 * of the license agreement you entered into with ACS.
 */

#import <Foundation/Foundation.h>

/**
 * The <code>AJDHex</code> class provides the conversion routines between the
 * HEX string and the byte array.
 * vice versa.
 * @author  Godfrey Chung
 * @version 1.0, 20 Feb 2014
 */
@interface AJDHex : NSObject

/**
 * Converts the byte array to HEX string.
 * @param buffer the buffer.
 * @param length the buffer length.
 * @return the HEX string.
 */
+ (NSString *)hexStringFromByteArray:(const uint8_t *)buffer length:(NSUInteger)length;

/**
 * Converts the byte array to HEX string.
 * @param buffer the buffer.
 * @return the HEX string.
 */
+ (NSString *)hexStringFromByteArray:(NSData *)buffer;

/**
 * Converts the HEX string to byte array.
 * @param hexString the HEX string.
 * @return the byte array.
 */
+ (NSData *)byteArrayFromHexString:(NSString *)hexString;

@end
