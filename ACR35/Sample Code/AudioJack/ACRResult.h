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
 * Error code.
 */
enum ACRError {

    ACRErrorSuccess              = 0x00,    /**< Success. */
    ACRErrorInvalidCommand       = 0xFF,    /**< Invalid command. */
    ACRErrorInvalidParameter     = 0xFE,    /**< Invalid parameters. */
    ACRErrorInvalidChecksum      = 0xFD,    /**< Invalid checksum. */
    ACRErrorInvalidStartByte     = 0xFC,    /**< Invalid start byte. */
    ACRErrorUnknown              = 0xFB,    /**< Unknown error. */
    ACRErrorDukptOperationCeased = 0xFA,    /**< DUKPT operation is ceased. */
    ACRErrorDukptDataCorrupted   = 0xF9,    /**< DUKPT data is corrupted. */
    ACRErrorFlashDataCorrupted   = 0xF8,    /**< Flash data is corrupted. */
    ACRErrorVerificationFailed   = 0xF7,    /**< Verification is failed. */
    ACRErrorPiccNoCard           = 0xF6     /**< No card in PICC slot. */
};

/**
 * The <code>ACRResult</code> class represents the result.
 * @author  Godfrey Chung
 * @version 1.0, 25 Apr 2013
 */
@interface ACRResult : NSObject

/**
 * Returns the error code.
 */
@property (nonatomic, readonly) NSUInteger errorCode;

/**
 * Returns an initialized <code>ACRResult</code> object from a given buffer of
 * bytes.
 * @param bytes  a buffer of bytes.
 * @param length the number of bytes.
 * @return an initialized <code>ACRResult</code> object.
 */
- (id)initWithBytes:(const void *)bytes length:(NSUInteger)length;

@end
