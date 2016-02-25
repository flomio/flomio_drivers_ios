/*
 * Copyright (C) 2013 Advanced Card Systems Ltd. All Rights Reserved.
 *
 * This software is the confidential and proprietary information of Advanced
 * Card Systems Ltd. ("Confidential Information").  You shall not disclose such
 * Confidential Information and shall use it only in accordance with the terms
 * of the license agreement you entered into with ACS.
 */

#import <Foundation/Foundation.h>

/**
 * The <code>ACRCRC16</code> class is used to compute a CRC16 checksum from data
 * provided as input value.
 * @author  Godfrey Chung
 * @version 1.0, 28 Mar 2013
 */
@interface ACRCRC16 : NSObject

/**
 * Returns the CRC16 checksum for all input received.
 * @return the checksum for this instance.
 */
- (uint16_t)value;

/**
 * Resets the CRC16 checksum to it initial state.
 */
- (void)reset;

/**
 * Update this CRC16 checksum with the contents of buffer and reading length
 * bytes of data.
 * @param bytes  the byte array from which to read the bytes.
 * @param length the number of bytes to read from buffer.
 */
- (void)updateWithBytes:(const void *)bytes length:(NSUInteger)length;

@end
