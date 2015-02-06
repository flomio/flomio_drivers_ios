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
 * The <code>ACRTrack2Data</code> class is used to decode the track 2 data into
 * fields specified by ISO/IEC 7813.
 * @author  Godfrey Chung
 * @version 1.0, 18 Apr 2013
 */
@interface ACRTrack2Data : NSObject

/**
 * Returns the track 2 string.
 */
@property (nonatomic, readonly) NSString *track2String;

/**
 * Returns the primary account number.
 */
@property (nonatomic, readonly) NSString *primaryAccountNumber;

/**
 * Returns the expiratiion date.
 */
@property (nonatomic, readonly) NSString *expirationDate;

/**
 * Returns the service code.
 */
@property (nonatomic, readonly) NSString *serviceCode;

/**
 * Returns the discretionary data.
 */
@property (nonatomic, readonly) NSString *discretionaryData;

/**
 * Returns an initialized <code>ACRTrack2Data</code> object from a given buffer
 * of bytes.
 * @param bytes  a buffer of bytes.
 * @param length the number of bytes.
 * @return an initialized <code>ACRTrack2Data</code> object.
 */
- (id)initWithBytes:(const void *)bytes length:(NSUInteger)length;

/**
 * Returns an initialized <code>ACRTrack2Data</code> object from a given string.
 * @param track2String the track 2 string.
 * @return an initialized <code>ACRTrack2Data</code> object.
 */
- (id)initWithString:(NSString *)track2String;

@end
