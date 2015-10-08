/*
 * Copyright (C) 2014 Advanced Card Systems Ltd. All Rights Reserved.
 *
 * This software is the confidential and proprietary information of Advanced
 * Card Systems Ltd. ("Confidential Information").  You shall not disclose such
 * Confidential Information and shall use it only in accordance with the terms
 * of the license agreement you entered into with ACS.
 */

#import <Foundation/Foundation.h>

/** ACS Bluetooth error domain. */
FOUNDATION_EXPORT NSString *const ABTErrorDomain;

// Bluetooth reader reserves the error code from 1 to 255.
enum {

    /** The checksum is invalid. */
    ABTErrorInvalidChecksum = 1,

    /** The data length is invalid. */
    ABTErrorInvalidDataLength = 2,

    /** The command is invalid. */
    ABTErrorInvalidCommand = 3,

    /** The command ID is unknown. */
    ABTErrorUnknownCommandId = 4,

    /** The card operation failed. */
    ABTErrorCardOperation = 5,

    /** Authentication is required. */
    ABTErrorAuthenticationRequired = 6,

    /** The battery is low. */
    ABTErrorLowBattery = 7,

    /** Authentication failed. */
    ABTErrorAuthenticationFailed = 8,

    /** The characteristic is not found. */
    ABTErrorCharacteristicNotFound = 1000,

    /** The service is not found. */
    ABTErrorServiceNotFound = 1001,

    /** The reader is not found. */
    ABTErrorReaderNotFound = 1002,

    /** The command failed. */
    ABTErrorCommandFailed = 1003,

    /** The operation timed out. */
    ABTErrorTimeout = 1004,

    /** The error is undefined. */
    ABTErrorUndefined = 1005,

    /** The data is invalid. */
    ABTErrorInvalidData = 1006
};
