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
 * The <code>ACRAesTrackData</code> class represents the track data after
 * swiping a card from the reader using AES mode.
 * @author  Godfrey Chung
 * @version 1.0, 21 Mar 2014
 */
@interface ACRAesTrackData : ACRTrackData

/** Track data. */
@property (nonatomic, readonly) NSData *trackData;

/**
 * Returns an initialized <code>ACRAesTrackData</code> object from a given
 * buffer of bytes.
 * @param bytes  a buffer of bytes.
 * @param length the number of bytes.
 * @return an initialized <code>ACRAesTrackData</code> object.
 */
- (id)initWithBytes:(const void *)bytes length:(NSUInteger)length;

@end
