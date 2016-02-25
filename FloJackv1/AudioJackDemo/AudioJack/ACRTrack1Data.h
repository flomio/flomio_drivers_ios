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
 * The <code>ACRTrack1Data</code> class is used to decode the track 1 data into
 * fields specified by ISO/IEC 7813.
 * @author  Godfrey Chung
 * @version 1.0, 18 Apr 2013
 */
@interface ACRTrack1Data : NSObject

/**
 * Returns the JIS2 data.
 */
@property (nonatomic, readonly) NSString *jis2Data;

/**
 * Returns the track 1 string.
 */
@property (nonatomic, readonly) NSString *track1String;

/**
 * Returns the primary account number.
 */
@property (nonatomic, readonly) NSString *primaryAccountNumber;

/**
 * Returns the name.
 */
@property (nonatomic, readonly) NSString *name;

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
 * Returns an initialized <code>ACRTrack1Data</code> object from a given buffer
 * of bytes.
 * @param bytes  a buffer of bytes.
 * @param length the number of bytes.
 * @return an initialized <code>ACRTrack1Data</code> object.
 */
- (id)initWithBytes:(const void *)bytes length:(NSUInteger)length;

/**
 * Returns an initialized <code>ACRTrack1Data</code> object from a given string.
 * @param track1String the track 1 string.
 * @return an initialized <code>ACRTrack1Data</code> object.
 */
- (id)initWithString:(NSString *)track1String;

@end
