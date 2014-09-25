ACS Audio Jack iOS Library
Advanced Card Systems Ltd.



Introduction
------------

This library provides classes and protocols for communicating with ACS audio
jack readers.

This library is based on Project HiJack. This project is to hijack power and
bandwidth from the mobile phone's audio interface and create a cubic-inch
peripheral sensor ecosystem for the mobile phone. See Project HiJack [1] for
more information.

To install the library to your development environment, see the section
"Installation".

[1] http://web.eecs.umich.edu/~prabal/projects/hijack/



Release Notes
-------------

Version:      1.0.0 Preview 7
Release Date: 15/5/2014

This preview library is subject to change. It may or may not work with your iOS
device.

System Requirements

- iOS 5.0 or above.
- iPhone 4S or above.

Development Environment

- Xcode 5.1.1 or above.

Supported Readers

- ACR31
- ACR32
- ACR35



Installation
------------

1. To use the class library to your project, copy "AudioJackDemo\AudioJack"
   folder to your project folder and drag it to your project in the Xcode.

2. Select Build Settings tab in the Targets.

3. Add "$(SRCROOT)/**" to the User Header Search Paths.

4. Add "-ObjC" to Other Linker Flags.

5. Select Build Phases in the Targets.

6. Add "AudioToolbox.framework to Link Binary With Libraries.



History
----------

Library

v1.0.0 Preview 7 (15/5/2014)
- Remove the limitation of command length in
  transmitApdu:length:slotNum:timeout:error: and
  transmitControlCommand:length:controlCode:slotNum:timeout:error: of
  ACRAudioJackReader class.
- Improve the sending speed.

v1.0.0 Preview 6 (10/4/2014)
- Change the ACRTrackData class to superclass.
- Add the following classes:
  ACRAesTrackData
  ACRDukptTrackData
  ACRDukptReceiver
- Add the following methods to ACRTrack1Data class:
  initWithString:
- Add the following methods to ACRTrack2Data class:
  initWithString:
- Add the following constants to ACRAudioJackReader class:
  ACRTrackDataOptionEncryptedTrack1
  ACRTrackDataOptionEncryptedTrack2
  ACRTrackDataOptionMaskedTrack1
  ACRTrackDataOptionMaskedTrack2
- Add the following methods to ACRAudioJackReader class:
  getTrackDataOption
  setTrackDataOption
- Add the following methods to ACRAudioJackReaderDelegate protocol:
  reader:didSendTrackDataOption:
- Handle ACRIoctlCcidXfrBlock in
  transmitControlCommand:length:controlCode:slotNum:timeout:error: method of
  ACRAudioJackReader class.
- Update the documentation.

v1.0.0 Preview 5 (28/2/2014)
- Fix a bug that the PICC ATR length plus 1 is returned.
- Fix a bug that the PICC response APDU length plus 1 is returned.
- Add the following constants to ACRAudioJackReader class:
  ACRCardPowerAction
  ACRCardProtocol
  ACRCardState
- Add the following methods to ACRAudioJackReader class:
  powerCardWithAction:slotNum:timeout:error:
  setProtocol:slotNum:timeout:error:
  transmitApdu:slotNum:timeout:error:
  transmitApdu:length:slotNum:timeout:error:
  transmitControlCommand:controlCode:slotNum:timeout:error:
  transmitControlCommand:length:controlCode:slotNum:timeout:error:
  getAtrWithSlotNumber:
  getStateWithSlotNumber:
  getProtocolWithSlotNumber:
- Add AudioJackErrors.h.

v1.0.0 Preview 4 (16/12/2013)
- Rename the project to AudioJack.
- Rename the class prefix to ACR.
- Add ACRPiccCardType constants.
- Add the following methods to ACRAudioJackReader class:
  piccPowerOnWithTimeout:cardType:
  piccTransmitWithTimeout:commandApdu:length:
  piccPowerOff
  setPiccRfConfig:length:
- Add the following methods to ACR31ReaderDelegate protocol:
  reader:didSendPiccAtr:length:
  reader:didSendPiccResponseApdu:length:
- Optimize the encoder performance.
- Limit the received message length to 300.
- Change the return type to void in authenticateWithMasterKey:length: and
  authenticateWithMasterKey:length:completion:

v1.0.0 Preview 3 (1/11/2013)
- Remove the 255 bytes limitation of response message length.
- Add the following error codes to ACR31TrackError enumeration:
  ACR31TrackErrorParity
- Add the following properties to ACR31TrackData class:
  keySerialNumber
- Add the following methods to ACR31Reader class:
  authenticateWithMasterKey:length:
  authenticateWithMasterKey:length:completion:
  getCustomId
  setCustomId:length:
  getDeviceId
  setMasterKey:length:
  setAesKey:length:
  getDukptOption
  setDukptOption:
  initializeDukptWithIksn:iksnLength:ipek:ipekLength:
  resetWithCompletion:
- Add the following methods to ACR31ReaderDelegate protocol:
  reader:didAuthenticate:
  reader:didSendCustomId:length:
  reader:didSendDeviceId:length:
  reader:didSendDukptOption:
- Add the following error codes to ACR31Error enumeration:
  ACR31ErrorDukptOperationCeased
  ACR31ErrorDukptDataCorrupted
  ACR31ErrorFlashDataCorrupted
  ACR31ErrorVerificationFailed

v1.0.0 Preview 2 (23/8/2013)
- Fix the NSDate memory leak problem.
- Add jis2Data property to ACR31Track1Data class.

v1.0.0 Preview 1 (6/5/2013)
- New release.



Demo

v1.0.0 Preview 6 (10/4/2014)
- Add track data setup.
- Show the track data using DUKPT.
- Fix a bug that the first 10 bytes of custom ID cannot be stored if the length
  is greater than 10 bytes.
- Allow to change the stored key and DUKPT settings.
- Set the reader to sleep before reset in setting custom ID, master key,
  AES key, DUKPT option and DUKPT initialization.
- Add "Use default key" to Cryptographic Keys UI.
- Add "Use default IKSN & IPEK" to DUKPT Setup UI.

v1.0.0 Preview 5 (28/2/2014)
- Add ICC.

v1.0.0 Preview 4 (16/12/2013)
- Rename the project to AudioJackDemo.
- Rename the class prefix to AJD.
- Add PICC.
- Change the display name to "AJ Demo".
- Change the wait timeout to 10 seconds.

v1.0.0 Preview 3 (1/11/2013)
- Add About Reader, Reader ID, Cryptographic Keys and DUKPT Setup.
- Rearrange the layout.

v1.0.0 Preview 2 (23/8/2013)
- Add the sleep timeout modification.
- Show the JIS2 data.
- Adjust the cell height for data received and JIS2 data.
- Rearrange the layout.

v1.0.0 Preview 1 (6/5/2013)
- New release.



File Contents
-------------

API Documentation:  AudioJack\doc
Sample Application: AudioJackDemo
Class Library:      AudioJackDemo\AudioJack



Support
-------

In case of problem, please contact ACS through:

Web Site: http://www.acs.com.hk/
E-mail: info@acs.com.hk
Tel: +852 2796 7873
Fax: +852 2796 1286



-------------------------------------------------------------------------------
Copyright (c) 2013-2014, Advanced Card Systems Ltd.
Copyright (c) 2011, CSE Division, EECS Department, University of Michigan.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

    Redistributions of source code must retain the above copyright notice, this
    list of conditions and the following disclaimer.

    Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.

    Neither the name of the University of Michigan nor the names of its
    contributors may be used to endorse or promote products derived from this
    software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (
INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

IOS is a trademark or registered trademark of Cisco in the U.S. and other
countries and is used under license.

iPhone is a trademark of Apple Inc.

Xcode is a trademark of Apple Inc.
