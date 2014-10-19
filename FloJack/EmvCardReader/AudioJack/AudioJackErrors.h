/*
 * Copyright (C) 2014 Advanced Card Systems Ltd. All Rights Reserved.
 *
 * This software is the confidential and proprietary information of Advanced
 * Card Systems Ltd. ("Confidential Information").  You shall not disclose such
 * Confidential Information and shall use it only in accordance with the terms
 * of the license agreement you entered into with ACS.
 */

#import <Foundation/Foundation.h>

/** Audio jack error domain. */
FOUNDATION_EXPORT NSString *const ACRAudioJackErrorDomain;

enum {

    /**
     * The card operation timed out.
     */
    ACRCardTimeoutError = 1,

    /**
     * There is an error occurred in the communication.
     */
    ACRCommunicationError = 2,

    /**
     * There is timeout in the communication.
     */
    ACRCommunicationTimeoutError = 3,

    /**
     * The state of reader is invalid.
     */
    ACRInvalidDeviceStateError = 4,

    /**
     * The requested protocols are incompatible with the protocol currently in
     * use with the card.
     */
    ACRProtocolMismatchError = 5,

    /**
     * The program attempts to access a card which is removed.
     */
    ACRRemovedCardError = 6,

    /**
     * The request queue is full.
     */
    ACRRequestQueueFullError = 7,

    /**
     * The program attempts to access a card which is not responding to a reset.
     */
    ACRUnresponsiveCardError = 8,

    /**
     * The program attempts to access a card which is not supported.
     */
    ACRUnsupportedCardError = 9
};
