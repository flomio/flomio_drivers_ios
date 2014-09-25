/*
 * Copyright (C) 2014 Advanced Card Systems Ltd. All Rights Reserved.
 *
 * This software is the confidential and proprietary information of Advanced
 * Card Systems Ltd. ("Confidential Information").  You shall not disclose such
 * Confidential Information and shall use it only in accordance with the terms
 * of the license agreement you entered into with ACS.
 */

#import "ACRTrackData.h"

/**
 * The <code>ACRDukptTrackData</code> class represents the track data after
 * swiping a card from the reader using DUKPT mode.
 * @author  Godfrey Chung
 * @version 1.0, 21 Mar 2014
 */
@interface ACRDukptTrackData : ACRTrackData

/** Track 1 data. */
@property (nonatomic, readonly) NSData *track1Data;

/** Track 1 MAC. */
@property (nonatomic, readonly) NSData *track1Mac;

/** Track 2 data. */
@property (nonatomic, readonly) NSData *track2Data;

/** Track 2 MAC. */
@property (nonatomic, readonly) NSData *track2Mac;

/** Track 1 masked data. */
@property (nonatomic, readonly) NSString *track1MaskedData;

/** Track 2 masked data. */
@property (nonatomic, readonly) NSString *track2MaskedData;

/** Key serial number. */
@property (nonatomic, readonly) NSData *keySerialNumber;

/**
 * Returns an initialized <code>ACRAesTrackData</code> object from a given
 * buffer of bytes.
 * @param bytes  a buffer of bytes.
 * @param length the number of bytes.
 * @return an initialized <code>ACRAesTrackData</code> object.
 */
- (id)initWithBytes:(const void *)bytes length:(NSUInteger)length;

@end
