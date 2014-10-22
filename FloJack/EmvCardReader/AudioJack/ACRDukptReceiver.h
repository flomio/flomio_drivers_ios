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
 * The <code>ACRDukptReceiver</code> class generates the future keys according
 * to ANSI X9.24-1:2009.
 * @author  Godfrey Chung
 * @version 1.0, 25 Mar 2014
 */
@interface ACRDukptReceiver : NSObject

/**
 * Gets the key serial number.
 * @return the key serial number.
 */
- (NSData *)keySerialNumber;

/**
 * Sets the key serial number.
 * @param keySerialNumber the key serial number.
 */
- (void)setKeySerialNumber:(NSData *)keySerialNumber;

/**
 * Sets the key serial number.
 * @param keySerialNumber the key serial number.
 * @param length          the key serial number length.
 */
- (void)setKeySerialNumber:(const uint8_t *)keySerialNumber length:(NSUInteger)length;

/**
 * Gets the encryption counter.
 * @return the encryption counter.
 */
- (NSUInteger)encryptionCounter;

/**
 * Loads the initial key.
 * @param initialKey the initial key. The length must be 16 bytes.
 */
- (void)loadInitialKey:(NSData *)initialKey;

/**
 * Loads the initial key.
 * @param initialKey the initial key. The length must be 16 bytes.
 * @param length     the initial key length.
 */
- (void)loadInitialKey:(const uint8_t *)initialKey length:(NSUInteger)length;

/**
 * Gets the key.
 * @return the key. <code>nil</code> if the maximum encryption count had been
 *         reached.
 */
- (NSData *)key;

/**
 * Generates the PIN encryption key from the key.
 * @param key the key. The length must be 16 bytes.
 * @return the PIN encryption key.
 */
+ (NSData *)pinEncryptionKeyFromKey:(NSData *)key;

/**
 * Generates the PIN encryption key from the key.
 * @param key    the key. The length must be 16 bytes.
 * @param length the key length.
 * @return the PIN encryption key.
 */
+ (NSData *)pinEncryptionKeyFromKey:(const uint8_t *)key length:(NSUInteger)length;

/**
 * Generates the MAC request key from the key.
 * @param key the key. The length must be 16 bytes.
 * @return the MAC request key.
 */
+ (NSData *)macRequestKeyFromKey:(NSData *)key;

/**
 * Generates the MAC request key from the key.
 * @param key    the key. The length must be 16 bytes.
 * @param length the key length.
 * @return the MAC request key.
 */
+ (NSData *)macRequestKeyFromKey:(const uint8_t *)key length:(NSUInteger)length;

/**
 * Generates the MAC response key from the key.
 * @param key the key. The length must be 16 bytes.
 * @return the MAC response key.
 */
+ (NSData *)macResponseKeyFromKey:(NSData *)key;

/**
 * Generates the MAC response key from the key.
 * @param key    the key. The length must be 16 bytes.
 * @param length the key length.
 * @return the MAC response key.
 */
+ (NSData *)macResponseKeyFromKey:(const uint8_t *)key length:(NSUInteger)length;

/**
 * Generates the data encryption request key from the key.
 * @param key the key. The length must be 16 bytes.
 * @return the data encryption request key.
 */
+ (NSData *)dataEncryptionRequestKeyFromKey:(NSData *)key;

/**
 * Generates the data encryption request key from the key.
 * @param key    the key. The length must be 16 bytes.
 * @param length the key length.
 * @return the data encryption request key.
 */
+ (NSData *)dataEncryptionRequestKeyFromKey:(const uint8_t *)key length:(NSUInteger)length;

/**
 * Generates the data encryption response key from the key.
 * @param key the key. The length must be 16 bytes.
 * @return the data encryption response key.
 */
+ (NSData *)dataEncryptionResponseKeyFromKey:(NSData *)key;

/**
 * Generates the data encryption response key from the key.
 * @param key    the key. The length must be 16 bytes.
 * @param length the key length.
 * @return the data encryption response key.
 */
+ (NSData *)dataEncryptionResponseKeyFromKey:(const uint8_t *)key length:(NSUInteger)length;

/**
 * Generates the MAC from the data.
 * @param data the data.
 * @param key  the key. The length must be 16 bytes.
 * @return the MAC.
 */
+ (NSData *)macFromData:(NSData *)data key:(NSData *)key;

/**
 * Generates the MAC from the data.
 * @param data       the data.
 * @param dataLength the data length.
 * @param key        the key. The length must be 16 bytes.
 * @param keyLength  the key length.
 * @return the MAC.
 */
+ (NSData *)macFromData:(const uint8_t *)data dataLength:(NSUInteger)dataLength key:(const uint8_t *)key keyLength:(NSUInteger)keyLength;

/**
 * Compares the tow key serial numbers.
 * @param ksn1 the first key serial number.
 * @param ksn2 the second key serial number.
 * @return <code>YES</code> if the two key serial numbers are equal, otherwise
 *         <code>NO</code>.
 */
+ (BOOL)compareKeySerialNumber:(NSData *)ksn1 ksn2:(NSData *)ksn2;

/**
 * Compares the tow key serial numbers.
 * @param ksn1       the first key serial number.
 * @param ksn1Length the first key serial number length.
 * @param ksn2       the second key serial number.
 * @param ksn2Length the second key serial number length.
 * @return <code>YES</code> if the two key serial numbers are equal, otherwise
 *         <code>NO</code>.
 */
+ (BOOL)compareKeySerialNumber:(const uint8_t *)ksn1 ksn1Length:(NSUInteger)ksn1Length ksn2:(const uint8_t *)ksn2 ksn2Length:(NSUInteger)ksn2Length;

/**
 * Gets the encryption counter from the key serial number.
 * @param ksn the key serial number. The length must be 10 bytes.
 * @return the encryption counter.
 */
+ (NSUInteger)encryptionCounterFromKeySerialNumber:(NSData *)ksn;

/**
 * Gets the encryption counter from the key serial number.
 * @param ksn    the key serial number. The length must be 10 bytes.
 * @param length the key serial number length.
 * @return the encryption counter.
 */
+ (NSUInteger)encryptionCounterFromKeySerialNumber:(const uint8_t *)ksn length:(NSUInteger)length;

@end
