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
 * Battery status.
 */
enum ACRBatteryStatus {

    ACRBatteryStatusLow  = 0,   /**< Battery is low. */
    ACRBatteryStatusFull = 1    /**< Battery is full. */
};

/**
 * Track error.
 */
enum ACRTrackError {

    ACRTrackErrorSuccess = 0x00,    /**< Success. */
    ACRTrackErrorSS      = 0x01,    /**< Invalid start sentinel on the track. */
    ACRTrackErrorES      = 0x02,    /**< Invalid end sentinel on the track. */
    ACRTrackErrorLRC     = 0x04,    /**< Invalid checksum on the track. */
    ACRTrackErrorParity  = 0x08     /**< Invalid parity on the track. */
};

/**
 * The <code>ACRTrackData</code> class represents the track data after swiping
 * a card from the reader.
 * @author  Godfrey Chung
 * @version 1.0, 8 Apr 2013
 */
@interface ACRTrackData : NSObject {

    NSUInteger _batteryStatus;      /**< Battery status. */
    NSUInteger _track1Length;       /**< Track 1 length. */
    NSUInteger _track1ErrorCode;    /**< Track 1 error code. */
    NSUInteger _track2Length;       /**< Track 2 length. */
    NSUInteger _track2ErrorCode;    /**< Track 2 error code. */
}

/** Battery status. */
@property (nonatomic, readonly) NSUInteger batteryStatus;

/** Track 1 length. */
@property (nonatomic, readonly) NSUInteger track1Length;

/** Track 1 error code. */
@property (nonatomic, readonly) NSUInteger track1ErrorCode;

/** Track 2 length. */
@property (nonatomic, readonly) NSUInteger track2Length;

/** Track 2 error code. */
@property (nonatomic, readonly) NSUInteger track2ErrorCode;

@end
