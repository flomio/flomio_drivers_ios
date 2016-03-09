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
 * Authentication error.
 */
enum ACRAuthError {

    ACRAuthErrorSuccess = 0,    /**< Success. */
    ACRAuthErrorFailure = 1,    /**< Failure. */
    ACRAuthErrorTimeout = 2     /**< Timeout. */
};

/**
 * PICC card type.
 */
enum ACRPiccCardType {

    ACRPiccCardTypeIso14443TypeA = 0x01,    /**< ISO14443 Type A. */
    ACRPiccCardTypeIso14443TypeB = 0x02,    /**< ISO14443 Type B. */
    ACRPiccCardTypeFelica212kbps = 0x04,    /**< FeliCa 212kbps. */
    ACRPiccCardTypeFelica424kbps = 0x08,    /**< FeliCa 424kbps. */
    ACRPiccCardTypeAutoRats      = 0x80     /**< Auto RATS. */
};

/**
 * Card power action.
 */
typedef enum {

    ACRCardPowerDown = 0,   /**< Power down the card. */
    ACRCardColdReset = 1,   /**< Cycle power and reset the card. */
    ACRCardWarmReset = 2    /**< Force a reset on the card. */
} ACRCardPowerAction;

/**
 * Card protocol.
 */
enum {

    /**
     * There is no active protocol.
     */
    ACRProtocolUndefined = 0x00000000,

    /**
     * T=0 is the active protocol.
     */
    ACRProtocolT0 = 0x00000001,

    /**
     * T=1 is the active protocol.
     */
    ACRProtocolT1 = 0x00000002,

    /**
     * Raw is the active protocol.
     */
    ACRProtocolRaw = 0x00010000,

    /**
     * This is the mask of ISO defined transmission protocols.
     */
    ACRProtocolTx = ACRProtocolT0 | ACRProtocolT1,

    /**
     * Use the default transmission parameters or card clock frequency.
     */
    ACRProtocolDefault = 0x80000000,

    /**
     * Use optimal transmission parameters or card clock frequency. This is the
     * default.
     */
    ACRProtocolOptimal = 0x00000000
};

/**
 * Card protocol.
 */
typedef NSUInteger ACRCardProtocol;

/**
 * Card state.
 */
typedef enum {

    /**
     * The library is unaware of the current state of the reader.
     */
    ACRCardUnknown = 0,

    /**
     * There is no card in the reader.
     */
    ACRCardAbsent = 1,

    /**
     * There is a card in the reader, but it has not been moved into position
     * for use.
     */
    ACRCardPresent = 2,

    /**
     * There is a card in the reader in position for use. The card is not
     * powered.
     */
    ACRCardSwallowed = 3,

    /**
     * Power is being provided to the card, but the library is unaware of the
     * mode of the card.
     */
    ACRCardPowered = 4,

    /**
     * The card has been reset and is awaiting PTS negotiation.
     */
    ACRCardNegotiable = 5,

    /**
     * The card has been reset and specific communication protocols have been
     * established.
     */
    ACRCardSpecific = 6
} ACRCardState;

/**
 * I/O control.
 */
enum {

    /**
     * Control code for sending escape command to the reader.
     */
    ACRIoctlCcidEscape = 3500,

    /**
     * Control code for sending APDU to the reader.
     */
    ACRIoctlCcidXfrBlock = 3600
};

/** Track data option. */
enum {

    /** Enable the encrypted track 1 data. */
    ACRTrackDataOptionEncryptedTrack1 = 0x01,

    /** Enable the encrypted track 2 data. */
    ACRTrackDataOptionEncryptedTrack2 = 0x02,

    /** Enable the masked track 1 data. */
    ACRTrackDataOptionMaskedTrack1 = 0x04,

    /** Enable the masked track 2 data. */
    ACRTrackDataOptionMaskedTrack2 = 0x08
};

/** Track data option. */
typedef NSUInteger ACRTrackDataOption;

@class ACRResult;
@class ACRStatus;
@class ACRTrackData;

/**
 * The <code>ACRAudioJackReader</code> class represents ACS audio jack readers.
 * @author  Godfrey Chung
 * @version 1.0, 27 Mar 2013
 */
@interface ACRAudioJackReader : NSObject

/**
 * <code>YES</code> to mute the audio output, otherwise <code>NO</code>.
 */
@property BOOL mute;

/**
 * Returns an initialized <code>ACRAudioJackReader</code> object with mute
 * option.
 * @param mute <code>YES</code> to mute the audio output, otherwise
 *             <code>NO</code>.
 * @return an initialized <code>ACRAudioJackReader</code> object.
 */
- (id)initWithMute:(BOOL)mute;

/**
 * Gets the delegate.
 */
- (id)delegate;

/**
 * Sets the delegate.
 * @param newDelegate the delegate.
 */
- (void)setDelegate:(id)newDelegate;

/**
 * Resets the reader.
 */
- (void)reset;

/**
 * Resets the reader using completion handler.
 * @param completion the block object to be executed when the reset ends.
 */
- (void)resetWithCompletion:(void (^)(void))completion;

/**
 * Sets the reader to sleep.
 * @return <code>YES</code> if the request is queued successfully, otherwise
 *         <code>NO</code>.
 */
- (BOOL)sleep;

/**
 * Gets the firmware version.
 * @return <code>YES</code> if the request is queued successfully, otherwise
 *         <code>NO</code>.
 */
- (BOOL)getFirmwareVersion;

/**
 * Gets the status.
 * @return <code>YES</code> if the request is queued successfully, otherwise
 *         <code>NO</code>.
 */
- (BOOL)getStatus;

/**
 * Sets the sleep timeout.
 * @param timeout the timeout value in seconds.
 * @return <code>YES</code> if the request is queued successfully, otherwise
 *         <code>NO</code>.
 */
- (BOOL)setSleepTimeout:(NSUInteger)timeout;

/**
 * Authenticates the reader.
 * @param masterKey the master key.
 * @param length    the master key length must be 16 bytes.
 */
- (void)authenticateWithMasterKey:(const uint8_t *)masterKey length:(NSUInteger)length;

/**
 * Authenticates the reader using completion handler.
 * @param masterKey  the master key.
 * @param length     the master key length must be 16 bytes.
 * @param completion the block object to be executed when the authentication
 *                   ends. The block has no return value and takes a single
 *                   NSInteger argument for an error code.
 */
- (void)authenticateWithMasterKey:(const uint8_t *)masterKey length:(NSUInteger)length completion:(void (^)(NSInteger))completion;

/**
 * Gets the custom ID from the reader.
 * @return <code>YES</code> if the request is queued successfully, otherwise
 *         <code>NO</code>.
 */
- (BOOL)getCustomId;

/**
 * Sets the custom ID to the reader. In order to proceed this operation, your
 * reader must be authenticated.
 * @param customId the custom ID.
 * @param length   the custom ID length must be 10 bytes.
 * @return <code>YES</code> if the request is queued successfully, otherwise
 *         <code>NO</code>.
 * @see ACRAudioJackReader::authenticateWithMasterKey:length:
 * @see ACRAudioJackReader::authenticateWithMasterKey:length:completion:
 */
- (BOOL)setCustomId:(const uint8_t *)customId length:(NSUInteger)length;

/**
 * Gets the device ID from the reader.
 * @return <code>YES</code> if the request is queued successfully, otherwise
 *         <code>NO</code>.
 */
- (BOOL)getDeviceId;

/**
 * Sets the master key to the reader. In order to proceed this operation, your
 * reader must be authenticated.
 * @param masterKey the master key.
 * @param length    the master key length must be 16 bytes.
 * @return <code>YES</code> if the request is queued successfully, otherwise
 *         <code>NO</code>.
 * @see ACRAudioJackReader::authenticateWithMasterKey:length:
 * @see ACRAudioJackReader::authenticateWithMasterKey:length:completion:
 */
- (BOOL)setMasterKey:(const uint8_t *)masterKey length:(NSUInteger)length;

/**
 * Sets the AES key to the reader. In order to proceed this operation, your
 * reader must be authenticated.
 * @param aesKey the AES key.
 * @param length the AES key length must be 16 bytes.
 * @return <code>YES</code> if the request is queued successfully, otherwise
 *         <code>NO</code>.
 * @see ACRAudioJackReader::authenticateWithMasterKey:length:
 * @see ACRAudioJackReader::authenticateWithMasterKey:length:completion:
 */
- (BOOL)setAesKey:(const uint8_t *)aesKey length:(NSUInteger)length;

/**
 * Gets the DUKPT option from the reader.
 * @return <code>YES</code> if the request is queued successfully, otherwise
 *         <code>NO</code>.
 */
- (BOOL)getDukptOption;

/**
 * Sets the DUKPT option to the reader. In order to proceed this operation, your
 * reader must be authenticated.
 * @param enabled set to true to enable DUKPT. Otherwise, set to false.
 * @return <code>YES</code> if the request is queued successfully, otherwise
 *         <code>NO</code>.
 * @see ACRAudioJackReader::authenticateWithMasterKey:length:
 * @see ACRAudioJackReader::authenticateWithMasterKey:length:completion:
 */
- (BOOL)setDukptOption:(BOOL)enabled;

/**
 * Initializes DUKPT to the reader. In order to proceed this operation, your
 * reader must be authenticated.
 * @param iksn       the initial key serial number (IKSN).
 * @param iksnLength the IKSN length must be 10 bytes.
 * @param ipek       the initial PIN encryption key (IPEK).
 * @param ipekLength the IPEK length must be 16 bytes.
 * @return <code>YES</code> if the request is queued successfully, otherwise
 *         <code>NO</code>.
 * @see ACRAudioJackReader::authenticateWithMasterKey:length:
 * @see ACRAudioJackReader::authenticateWithMasterKey:length:completion:
 */
- (BOOL)initializeDukptWithIksn:(const uint8_t *)iksn iksnLength:(NSUInteger)iksnLength ipek:(const uint8_t *)ipek ipekLength:(NSUInteger)ipekLength;

/**
 * Gets the track data option from the reader.
 * @return <code>YES</code> if the request is queued successfully, otherwise
 *         <code>NO</code>.
 */
- (BOOL)getTrackDataOption;

/**
 * Sets the track data option to the reader. In order to proceed this operation,
 * your reader must be authenticated.
 * @param option the track data option. See ::ACRTrackDataOptionEncryptedTrack1,
 *               ::ACRTrackDataOptionEncryptedTrack2,
 *               ::ACRTrackDataOptionMaskedTrack1 and
 *               ::ACRTrackDataOptionMaskedTrack2. It can be combined with OR
 *               operation.
 * @return <code>YES</code> if the request is queued successfully, otherwise
 *         <code>NO</code>.
 * @see ACRAudioJackReader::authenticateWithMasterKey:length:
 * @see ACRAudioJackReader::authenticateWithMasterKey:length:completion:
 */
- (BOOL)setTrackDataOption:(ACRTrackDataOption)option;

/**
 * Powers on the PICC.
 * @param timeout  the timeout value in seconds.
 * @param cardType the card type. See {@link #ACRPiccCardType}. It can be
 *                 combined with OR operation.
 * @return <code>YES</code> if the request is queued successfully, otherwise
 *         <code>NO</code>.
 */
- (BOOL)piccPowerOnWithTimeout:(NSUInteger)timeout cardType:(NSUInteger)cardType;

/**
 * Transmits the command APDU to the PICC.
 * @param timeout     the timeout value in seconds.
 * @param commandApdu the command APDU.
 * @param length      the command APDU length.
 * @return <code>YES</code> if the request is queued successfully, otherwise
 *         <code>NO</code>.
 */
- (BOOL)piccTransmitWithTimeout:(NSUInteger)timeout commandApdu:(const uint8_t *)commandApdu length:(NSUInteger)length;

/**
 * Powers off the PICC.
 * @return <code>YES</code> if the request is queued successfully, otherwise
 *         <code>NO</code>.
 */
- (BOOL)piccPowerOff;

/**
 * Sets the PICC RF configuration.
 * @param rfConfig the RF configuration. The length must be 19 bytes.
 * @param length   the RF configuration length.
 * @return <code>YES</code> if the request is queued successfully, otherwise
 *         <code>NO</code>.
 */
- (BOOL)setPiccRfConfig:(const uint8_t *)rfConfig length:(NSUInteger)length;

/**
 * Performs the power action on the card.
 * @param action   the action to be performed on the card. See
 *                 ::ACRCardPowerAction.
 * @param slotNum  the slot number.
 * @param timeout  the maximum time to wait in seconds.
 * @param errorPtr if there is an error, upon return contains an
 *                 <code>NSError</code> object that describes the problem.
 * @return the ATR string if cold reset or warm reset succeeds, otherwise
 *         <code>nil</code>.
 */
- (NSData *)powerCardWithAction:(ACRCardPowerAction)action slotNum:(NSUInteger)slotNum timeout:(NSTimeInterval)timeout error:(NSError **)errorPtr;

/**
 * Sets the protocol.
 * @param preferredProtocols the preferred protocols. It can be combined with OR
 *                           operation. For example,
 *                           ::ACRProtocolT0 | ::ACRProtocolT1.
 * @param slotNum            the slot number.
 * @param timeout            the maximum time to wait in seconds.
 * @param errorPtr           if there is an error, upon return contains an
 *                           <code>NSError</code> object that describes the
 *                           problem.
 * @return the active protocol. Either ::ACRProtocolT0 or ::ACRProtocolT1 if the
 *         operation succeeds, otherwise ::ACRProtocolUndefined.
 */
- (ACRCardProtocol)setProtocol:(ACRCardProtocol)preferredProtocols slotNum:(NSUInteger)slotNum timeout:(NSTimeInterval)timeout error:(NSError **)errorPtr;

/**
 * Transmits the APDU.
 * @param command  the command APDU.
 * @param slotNum  the slot number.
 * @param timeout  the maximum time to wait in seconds.
 * @param errorPtr if there is an error, upon return contains an
 *                 <code>NSError</code> object that describes the problem.
 * @return the response APDU if the operation succeeds, otherwise
 *         <code>nil</code>.
 */
- (NSData *)transmitApdu:(NSData *)command slotNum:(NSUInteger)slotNum timeout:(NSTimeInterval)timeout error:(NSError **)errorPtr;

/**
 * Transmits the APDU.
 * @param command  the command APDU.
 * @param length   the command APDU length.
 * @param slotNum  the slot number.
 * @param timeout  the maximum time to wait in seconds.
 * @param errorPtr if there is an error, upon return contains an
 *                 <code>NSError</code> object that describes the problem.
 * @return the response APDU if the operation succeeds, otherwise
 *         <code>nil</code>.
 */
- (NSData *)transmitApdu:(const uint8_t *)command length:(NSUInteger)length slotNum:(NSUInteger)slotNum timeout:(NSUInteger)timeout error:(NSError **)errorPtr;

/**
 * Transmits the control command.
 * @param command     the control command.
 * @param controlCode the control code.
 * @param slotNum     the slot number.
 * @param timeout     the maximum time to wait in seconds.
 * @param errorPtr    if there is an error, upon return contains an
 *                    <code>NSError</code> object that describes the problem.
 * @return the control response if the operation succeeds, otherwise
 *         <code>nil</code>.
 */
- (NSData *)transmitControlCommand:(NSData *)command controlCode:(NSUInteger)controlCode slotNum:(NSUInteger)slotNum timeout:(NSTimeInterval)timeout error:(NSError **)errorPtr;

/**
 * Transmits the control command.
 * @param command     the control command.
 * @param length      the control command length.
 * @param controlCode the control code.
 * @param slotNum     the slot number.
 * @param timeout     the maximum time to wait in seconds.
 * @param errorPtr    if there is an error, upon return contains an
 *                    <code>NSError</code> object that describes the problem.
 * @return the control response if the operation succeeds, otherwise
 *         <code>nil</code>.
 */
- (NSData *)transmitControlCommand:(const uint8_t *)command length:(NSUInteger)length controlCode:(NSUInteger)controlCode slotNum:(NSUInteger)slotNum timeout:(NSTimeInterval)timeout error:(NSError **)errorPtr;

/**
 * Updates the card state.
 * @param slotNum  the slot number.
 * @param timeout  the maximum time to wait in seconds.
 * @param errorPtr if there is an error, upon return contains an
 *                 <code>NSError</code> object that describes the problem.
 */
- (void)updateCardStateWithSlotNumber:(NSUInteger)slotNum timeout:(NSTimeInterval)timeout error:(NSError **)errorPtr;

/**
 * Gets the ATR string.
 * @param slotNum the slot number.
 * @return the ATR string.
 */
- (NSData *)getAtrWithSlotNumber:(NSUInteger)slotNum;

/**
 * Gets the card state.
 * @param slotNum the slot number.
 * @return the card state. See ::ACRCardState.
 */
- (ACRCardState)getCardStateWithSlotNumber:(NSUInteger)slotNum;

/**
 * Gets the active protocol.
 * @param slotNum the slot number.
 * @return the active protocol. See ::ACRCardProtocol.
 */
- (ACRCardProtocol)getProtocolWithSlotNumber:(NSUInteger)slotNum;

/**
 * Sends a command to the reader.
 * @param buffer the buffer.
 * @param length the buffer length.
 * @return <code>YES</code> if the request is queued successfully, otherwise
 *         <code>NO</code>.
 */
- (BOOL)sendCommand:(const void *)buffer length:(NSUInteger)length;

/**
 * Creates a frame.
 * @param buffer the buffer.
 * @param length the buffer length.
 * @return the frame data.
 */
- (NSData *)createFrame:(const void *)buffer length:(NSUInteger)length;

/**
 * Sends a frame to the reader.
 * @param frameData the frame data.
 * @return <code>YES</code> if the request is queued successfully, otherwise
 *         <code>NO</code>.
 */
- (BOOL)sendFrame:(NSData *)frameData;

/**
 * Verifies the data using CRC16 checksum. The checksum is located at the last 2
 * bytes of data.
 * @param buffer the buffer.
 * @param length the buffer length.
 * @return <code>YES</code> if the checksum is correct, otherwise
 *         <code>NO</code>.
 */
- (BOOL)verifyData:(const void *)buffer length:(NSUInteger)length;

@end

/**
 * The <code>ACRAudioJackReaderDelegate</code> protocol defines the response
 * sent to a delegate of <code>ACRAudioJackReader</code> object.
 */
@protocol ACRAudioJackReaderDelegate <NSObject>
@optional

/**
 * Tells the delegate that the reader had been reset.
 * @param reader the reader.
 */
- (void)readerDidReset:(ACRAudioJackReader *)reader;

/**
 * Tells the delegate that the reader notified the result.
 * @param reader the reader.
 * @param result the result.
 */
- (void)reader:(ACRAudioJackReader *)reader didNotifyResult:(ACRResult *)result;

/**
 * Tells the delegate that the reader sent the firmware version.
 * @param reader          the reader.
 * @param firmwareVersion the firmware version.
 */
- (void)reader:(ACRAudioJackReader *)reader didSendFirmwareVersion:(NSString *)firmwareVersion;

/**
 * Tells the delegate that the reader sent the status.
 * @param reader the reader.
 * @param status the status.
 */
- (void)reader:(ACRAudioJackReader *)reader didSendStatus:(ACRStatus *)status;

/**
 * Tells the delegate that the reader notified the track data.
 * @param reader the reader.
 */
- (void)readerDidNotifyTrackData:(ACRAudioJackReader *)reader;

/**
 * Tells the delegate that the reader sent the track data.
 * @param reader    the reader.
 * @param trackData the track data.
 */
- (void)reader:(ACRAudioJackReader *)reader didSendTrackData:(ACRTrackData *)trackData;

/**
 * Tells the delegate that the reader sent the raw data.
 * @param reader  the reader.
 * @param rawData the raw data.
 * @param length  the raw data length.
 */
- (void)reader:(ACRAudioJackReader *)reader didSendRawData:(const uint8_t *)rawData length:(NSUInteger)length;

/**
 * Tells the delegate that the reader had been authenticated.
 * @param reader    the reader.
 * @param errorCode the error code from ACRAuthError.
 */
- (void)reader:(ACRAudioJackReader *)reader didAuthenticate:(NSInteger)errorCode;

/**
 * Tells the delegate that the reader sent the custom ID.
 * @param reader   the reader.
 * @param customId the custom ID.
 * @param length   the custom ID length.
 */
- (void)reader:(ACRAudioJackReader *)reader didSendCustomId:(const uint8_t *)customId length:(NSUInteger)length;

/**
 * Tells the delegate that the reader sent the device ID.
 * @param reader   the reader.
 * @param deviceId the device ID.
 * @param length   the device ID length.
 */
- (void)reader:(ACRAudioJackReader *)reader didSendDeviceId:(const uint8_t *)deviceId length:(NSUInteger)length;

/**
 * Tells the delegate that the reader sent the DUKPT option.
 * @param reader  the reader.
 * @param enabled true if DUKPT is enabled.
 */
- (void)reader:(ACRAudioJackReader *)reader didSendDukptOption:(BOOL)enabled;

/**
 * Tells the delegate that the reader sent the track data option.
 * @param reader the reader.
 * @param option the track data option. See ::ACRTrackDataOptionEncryptedTrack1,
 *               ::ACRTrackDataOptionEncryptedTrack2,
 *               ::ACRTrackDataOptionMaskedTrack1 and
 *               ::ACRTrackDataOptionMaskedTrack2.
 */
- (void)reader:(ACRAudioJackReader *)reader didSendTrackDataOption:(ACRTrackDataOption)option;

/**
 * Tells the delegate that the reader sent the ATR from PICC.
 * @param reader the reader.
 * @param atr    the ATR.
 * @param length the ATR length.
 */
- (void)reader:(ACRAudioJackReader *)reader didSendPiccAtr:(const uint8_t *)atr length:(NSUInteger)length;

/**
 * Tells the delegate that the reader sent the response APDU from PICC.
 * @param reader       the reader.
 * @param responseApdu the response APDU.
 * @param length       the response APDU length.
 */
- (void)reader:(ACRAudioJackReader *)reader didSendPiccResponseApdu:(const uint8_t *)responseApdu length:(NSUInteger)length;

@end
