/*
 * Copyright (C) 2013 Advanced Card Systems Ltd. All Rights Reserved.
 *
 * This software is the confidential and proprietary information of Advanced
 * Card Systems Ltd. ("Confidential Information").  You shall not disclose such
 * Confidential Information and shall use it only in accordance with the terms
 * of the license agreement you entered into with ACS.
 */

#import <AudioJack/ACRCRC16.h>
#import <AudioJack/ACRAudioJackReader.h>
#import <AudioJack/ACRResult.h>
#import <AudioJack/ACRStatus.h>
#import <AudioJack/ACRTrack1Data.h>
#import <AudioJack/ACRTrack2Data.h>
#import <AudioJack/ACRTrackData.h>
#import <AudioJack/ACRAesTrackData.h>
#import <AudioJack/ACRDukptTrackData.h>
#import <AudioJack/ACRDukptReceiver.h>
#import <AudioJack/AudioJackErrors.h>

/**
@mainpage

@section intro Introduction

This library provides classes and protocols for communicating with ACS audio
jack readers on iOS 5.0 or above.

Your application should include a header file <code>AudioJack.h</code> in order
to use the classes and protocols provided by the library.

@code
//
// MyViewController.h
//

#import <UIKit/UIKit.h>
#import <AudioJack/AudioJack.h>

...

@interface MyViewController : UIViewController <ACRAudioJackReaderDelegate>

...

@end
@endcode

To use <code>ACRAudioJackReader</code> class, you should assign a delegate to
your reader. Your delegate object is responsibe for receiving the data from the
reader and should conform to the <code>ACRAudioJackReaderDelegate</code>
protocol.

@code
//
// MyViewController.m
//

#import "MyViewController.h"

...

@implementation MyViewController {

    ...

    ACRAudioJackReader *_reader;

    ...
}

...

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    ...

    // Initialize ACRAudioJackReader object.
    _reader = [[ACRAudioJackReader alloc] init];
    [_reader setDelegate:self];

    ...
}

...
@endcode

@section reset Resetting the reader

The sleep mode of reader is enabled by default. To use the reader, your
application should call ACRAudioJackReader::reset method. If your delegate
object implements ACRAudioJackReaderDelegate::readerDidReset: method, it will
receive a notification after the operation is completed.

@code
...

// Reset the reader.
[_reader reset];

...

#pragma mark - Audio Jack Reader

...

- (void)readerDidReset:(ACRAudioJackReader *)reader {

    // TODO: Add code here to process the notification.
    ...
}

...
@endcode

@section sleepmode Controlling the sleep mode

You can enable the sleep mode by calling ACRAudioJackReader::sleep method. If
your delegate object implements
ACRAudioJackReaderDelegate::reader:didNotifyResult: method, it will receive a
notification after the operation is completed.

@code
...

// Enable the sleep mode.
[_reader sleep];

...

#pragma mark - Audio Jack Reader

...

- (void)reader:(ACRAudioJackReader *)reader didNotifyResult:(ACRResult *)result {

    // TODO: Add code here to process the notification.
    ...
}

...
@endcode

@section sleeptimeout Setting the sleep timeout

You can set the sleep timeout by calling ACRAudioJackReader::setSleepTimeout
method. If your delegate object implements
ACRAudioJackReaderDelegate::reader:didNotifyResult: method, it will receive a
notification after the operation is completed.

@code
...

// Set the sleep timeout to 10 seconds.
[_reader setSleepTimeout:10];

...

#pragma mark - Audio Jack Reader

...

- (void)reader:(ACRAudioJackReader *)reader didNotifyResult:(ACRResult *)result {

    // TODO: Add code here to process the notification.
    ...
}

...
@endcode

@section firmware Getting the firmware version

To get the firmware version, your application should call
ACRAudioJackReader::getFirmwareVersion method. Your delegate object should
implement ACRAudioJackReaderDelegate::reader:didSendFirmwareVersion: method in
order to receive the firmware version.

@code
...

// Get the firmware version.
[_reader getFirmwareVersion];

...

#pragma mark - Audio Jack Reader

...

- (void)reader:(ACRAudioJackReader *)reader
    didSendFirmwareVersion:(NSString *)firmwareVersion {

    // TODO: Add code here to process the firmware version.
    ...
}

...
@endcode

@section status Getting the status

To get the status, your application should call ACRAudioJackReader::getStatus
method. Your delegate object should implement
ACRAudioJackReaderDelegate::reader:didSendStatus: method in order to receive the
status.

@code
...

// Get the status.
[_reader getStatus];

...

#pragma mark - Audio Jack Reader

...

- (void)reader:(ACRAudioJackReader *)reader didSendStatus:(ACRStatus *)status {

    // TODO: Add code here to process the status.
    ...
}

...
@endcode

@section track Receiving the track data

When you swipe a card, the reader notifies a track data and sends it through an
audio channel to your iOS device. To receive the notification and the track
data, your delegate object should implement
ACRAudioJackReaderDelegate::readerDidNotifyTrackData: and
ACRAudioJackReaderDelegate::reader:didSendTrackData: method. You can check the
track error using ACRTrackData::track1ErrorCode and
ACRTrackData::track2ErrorCode properties. Note that the received ACRTrackData
object will be the instance of ACRAesTrackData or ACRDukptTrackData according to
the settings. You must check the type of instance before accessing the object.

You can get the track data using ACRAesTrackData::trackData,
ACRDukptTrackData::track1Data and ACRDukptTrackData::track2Data properties. Note
that the track data of ACRAesTrackData object is encrypted by AES while the
track data of ACRDukptTrackData object is encrypted by Triple DES. You must
decrypt it before accessing the original track data.

After decrypting the track data of ACRAesTrackData object, you can use
ACRTrack1Data::initWithBytes:length: and ACRTrack2Data::initWithBytes:length:
methods to decode the track data into fields. For the track data or masked track
data of ACRDukptTrackData object, you can use ACRTrack1Data::initWithString: and
ACRTrack2Data::initWithString: methods.

@code
...

#pragma mark - Audio Jack Reader

...

- (void)readerDidNotifyTrackData:(ACRAudioJackReader *)reader {

    // TODO: Add your code here to process the notification.
    ...
}

...

- (void)reader:(ACRAudioJackReader *)reader
    didSendTrackData:(ACRTrackData *)trackData {

    // TODO: Add code here to process the track data.
    if ((trackData.track1ErrorCode != ACRTrackErrorSuccess) ||
        (trackData.track2ErrorCode != ACRTrackErrorSuccess)) {

        // Show the track error.
        ...

        return;
    }

    if ([trackData isKindOfClass:[ACRAesTrackData class]]) {

        ACRAesTrackData *aesTrackData = (ACRAesTrackData *) trackData;

        ...

    } else if ([trackData isKindOfClass:[ACRDukptTrackData class]]) {

        ACRDukptTrackData *dukptTrackData = (ACRDukptTrackData *) trackData;

        ...
    }

    ...
}

...
@endcode

@section raw Receiving the raw data

If you want to access a raw data of a response, your delegate object should
implement ACRAudioJackReaderDelegate::reader:didSendRawData:length: method. Note
that the raw data is not verified by CRC16 checksum and you can call
ACRAudioJackReader::verifyData:length: method to verify it.

@code
...

#pragma mark - Audio Jack Reader

...

- (void)reader:(ACRAudioJackReader *)reader
    didSendRawData:(const uint8_t *)rawData length:(NSUInteger)length {

    // TODO: Add code here to process the raw data.
    ...
}

...
@endcode

@section icc Working with the ICC

If your reader came with the ICC interface, you can operate the card using the
following methods:

- ACRAudioJackReader::powerCardWithAction:slotNum:timeout:error:
- ACRAudioJackReader::setProtocol:slotNum:timeout:error:
- ACRAudioJackReader::transmitApdu:slotNum:timeout:error:
- ACRAudioJackReader::transmitApdu:length:slotNum:timeout:error:
- ACRAudioJackReader::transmitControlCommand:controlCode:slotNum:timeout:error:
- ACRAudioJackReader::transmitControlCommand:length:controlCode:slotNum:timeout:error:
- ACRAudioJackReader::updateCardStateWithSlotNumber:timeout:error:
- ACRAudioJackReader::getAtrWithSlotNumber:
- ACRAudioJackReader::getCardStateWithSlotNumber:
- ACRAudioJackReader::getProtocolWithSlotNumber:

Before transmitting the APDU, you need to reset the card using
ACRAudioJackReader::powerCardWithAction:slotNum:timeout:error: method. The ATR
string will be returned if the card is operated normally. Otherwise, it will
return the error code.

After resetting the card, the card state is changed to ::ACRCardNegotiable or
::ACRCardSpecific. You cannot transmit the APDU if the card state is not equal
to ::ACRCardSpecific. To select the protocol, invoke
ACRAudioJackReader::setProtocol:slotNum:timeout:error: method with the preferred
protocols.

After selecting the protocol, you can transmit the command APDU using
ACRAudioJackReader::transmitApdu:slotNum:timeout:error: or
ACRAudioJackReader::transmitApdu:length:slotNum:timeout:error: method.

@code
...

NSUInteger slotNum = 0;
ACRCardPowerAction powerAction = ACRCardWarmReset;
NSTimeInterval timeout = 10;    // 10 seconds.
NSData *atr = nil;
ACRCardProtocol protocols = ACRProtocolT0 | ACRProtocolT1;
ACRCardProtocol activeProtocol = 0;
uint8_t commandApdu[] = { 0x00, 0x84, 0x00, 0x00, 0x08 };
NSData *responseApdu = nil;
NSError *error = nil;

...

// Reset the card.
atr = [_reader powerCardWithAction:powerAction slotNum:slotNum timeout:timeout
    error:&error];
if (atr != nil) {

    // Set the protocol.
    activeProtocol = [_reader setProtocol:protocols slotNum:slotNum
        timeout:timeout error:&error];

    // Transmit the APDU.
    responseApdu = [_reader transmitApdu:commandApdu length:sizeof(commandApdu)
        slotNum:slotNum timeout:timeout error:&error];
}

...
@endcode

You can transmit the control command to the reader using
ACRAudioJackReader::transmitControlCommand:controlCode:slotNum:timeout:error: or
ACRAudioJackReader::transmitControlCommand:length:controlCode:slotNum:timeout:error:
method if the reader supports a set of escape commands.

@code
...

NSUInteger controlCode = ACRIoctlCcidEscape;
uint8_t controlCommand[] = { 0xE0, 0x00, 0x00, 0x18, 0x00 };
NSData *controlResponse = nil;

...

// Transmit the control command.
controlResponse = [_reader transmitControlCommand:controlCommand
    controlCode:controlCode slotNum:slotNum timeout:timeout error:&error];

...
@endcode

@section picc Working with the PICC

If your reader came with the PICC interface, you can operate the card using the
following methods:

- ACRAudioJackReader::piccPowerOnWithTimeout:cardType:
- ACRAudioJackReader::piccTransmitWithTimeout:commandApdu:length:
- ACRAudioJackReader::piccPowerOff

Before transmitting the APDU, you need to power on the card using
ACRAudioJackReader::piccPowerOnWithTimeout:cardType: method. If your delegate
object implements ACRAudioJackReaderDelegate::reader:didSendPiccAtr:length
method, it will receive the ATR string from the card.

To transmit the APDU, you can use
ACRAudioJackReader::piccTransmitWithTimeout:commandApdu:length: method. If your
delegate object implements
ACRAudioJackReaderDelegate::reader:didSendPiccResponseApdu:length method, it
will receive the response APDU from the card.

After using the card, you can pwoer off the card using
ACRAudioJackReader::piccPowerOff method. If your delegate object implements
ACRAudioJackReaderDelegate::reader:didNotifyResult: method, it will receive a
notification after the operation is completed.

@code
...

NSUInteger timeout = 1; // 1 second.
NSUInteger cardType = ACRPiccCardTypeIso14443TypeA |
    ACRPiccCardTypeIso14443TypeB |
    ACRPiccCardTypeFelica212kbps |
    ACRPiccCardTypeFelica424kbps |
    ACRPiccCardTypeAutoRats;
uint8_t commandApdu[] = { 0x00, 0x84, 0x00, 0x00, 0x08 };

...

// Power on the PICC.
[_reader piccPowerOnWithTimeout:timeout cardType:cardType];

...

// Transmit the APDU.
[_reader piccTransmitWithTimeout:timeout commandApdu:commandApdu
    length:sizeof(commandApdu)];

...

// Power off the PICC.
[_reader piccPowerOff];

...

#pragma mark - Audio Jack Reader

...

- (void)reader:(ACRAudioJackReader *)reader didSendPiccAtr:(const uint8_t *)atr
    length:(NSUInteger)length {

    // TODO: Add code here to process the ATR.
    ...
}

- (void)reader:(ACRAudioJackReader *)reader
    didSendPiccResponseApdu:(const uint8_t *)responseApdu
    length:(NSUInteger)length {

    // TODO: Add code here to process the response APDU.
    ...
}

- (void)reader:(ACRAudioJackReader *)reader didNotifyResult:(ACRResult *)result {

    // TODO: Add code here to process the notification.
    ...
}

...
@endcode
*/
