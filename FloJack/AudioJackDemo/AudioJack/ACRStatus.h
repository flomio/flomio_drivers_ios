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
 * The <code>ACRStatus</code> class represents the status.
 * @author  Godfrey Chung
 * @version 1.0, 8 Apr 2013
 */
@interface ACRStatus : NSObject

/**
 * Returns the battery level.
 * <table>
 * <tr><th>Value</th><th>Meaning</th></tr>
 * <tr><td>00h</td><td>Battery Level &gt;= 3.0V</td></tr>
 * <tr><td>01h</td><td>2.9 &lt;= Battery Level &lt; 3.0V</td></tr>
 * <tr><td>02h</td><td>2.8 &lt;= Battery Level &lt; 2.9V</td></tr>
 * <tr><td>03h</td><td>2.7 &lt;= Battery Level &lt; 2.8V</td></tr>
 * <tr><td>04h</td><td>2.6 &lt;= Battery Level &lt; 2.7V</td></tr>
 * <tr><td>05h</td><td>2.5 &lt;= Battery Level &lt; 2.6V</td></tr>
 * <tr><td>06h</td><td>2.4 &lt;= Battery Level &lt; 2.5V</td></tr>
 * <tr><td>07h</td><td>2.3 &lt;= Battery Level &lt; 2.4V</td></tr>
 * <tr><td>08h</td><td>Battery Level &lt; 2.3V</td></tr>
 * </table>
 */
@property (nonatomic, readonly) NSUInteger batteryLevel;

/**
 * Returns the sleep timeout in seconds.
 */
@property (nonatomic, readonly) NSUInteger sleepTimeout;

/**
 * Returns an initialized <code>ACRStatus</code> object from a given buffer of
 * bytes.
 * @param bytes  a buffer of bytes.
 * @param length the number of bytes.
 * @return an initialized <code>ACRStatus</code> object.
 */
- (id)initWithBytes:(const void *)bytes length:(NSUInteger)length;

@end
