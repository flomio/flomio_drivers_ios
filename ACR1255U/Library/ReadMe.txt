ACS Bluetooth iOS/Mac OS X Library
Advanced Card Systems Ltd.



Introduction
------------

This library provides classes and protocols for communicating with ACS bluetooth
readers.

To install the library to your development environment, see the section
"Installation".



Release Notes
-------------

Version:      1.0.0 Preview 6
Release Date: 28/1/2016

This preview library is subject to change. It may or may not work with your iOS
device or Mac.

System Requirements

- iOS 5.0 or above.
- iPhone 4S or above.

- Mac OS X 10.7 or above.
- Mac with Bluetooth 4.0.

Development Environment

- Xcode 7.2 or above.

Supported Readers

- ACR3901U-S1 (v1.04 or above)
- ACR1255U-J1 (v1.12 or above)



Installation
------------

1. To use the class library to your project, copy "BTDemo\ACSBluetooth"
   folder to your project folder and drag it to your project in the Xcode.

2. Select Build Settings tab in the Targets.

3. Add "$(PROJECT_DIR)" to the Header Search Paths.

4. Add "-ObjC" to Other Linker Flags.



History
-------

Library

v1.0.0 Preview 6 (28/1/2016)
- Update to recommended settings in Xcode 7.2.
- Enable ABTBluetoothReaderDeviceInfoSerialNumberString in
  getDeviceInfoWithType: of ABTAcr1255uj1Reader class.

v1.0.0 Preview 5 (29/5/2015)
- Require ACR3901U-S1 v1.04 or above.
- Require ACR1255U-J1 v1.12 or above.
- Add the following methods to ABTBluetoothReader class:
  authenticateWithMasterKey:
  authenticateWithMasterKey:length:
- Add the following error code to ABTError.h:
  ABTErrorUndefined
  ABTErrorInvalidData
  ABTErrorAuthenticationRequired (renamed from ABTErrorAuthRequired)
  ABTErrorAuthenticationFailed (renamed from ABTErrorAuthFailed)
  ABTErrorTimeout (renamed from ABTErrorOperationTimeout)
- Remap the error codes in ABTError.h.
- Update the documentation.

v1.0.0 Preview 4 (14/8/2014)
- Add the following error code to ABTError.h:
  ABTErrorReaderNotFound
  ABTErrorCommandFailed
  ABTErrorOperationTimeout
- Convert ABTBluetoothReader to an abstract class.
- Add the following classes:
  ABTAcr3901us1Reader
  ABTAcr1255uj1Reader
  ABTBluetoothReaderManager
- Update the documentation.

v1.0.0 Preview 3 (18/7/2014)
- Add Mac OS X support.
- Check the returned services from the reader.
- Add ABTErrorServiceNotFound to ABTError.h.
- Return the empty string if there is an error in converting the string in
  device information.
- Update the documentation.

v1.0.0 Preview 2 (6/6/2014)
- Fix the receiving problem if the last block size is equal to the default block
  size.

v1.0.0 Preview 1 (30/5/2014)
- New release.



Demo (iOS)

v1.0.0 Preview 5 (28/1/2016)
- Update to recommended settings in Xcode 7.2.
- Update the build to 5.

v1.0.0 Preview 4 (29/5/2015)
- Set the row height to 44 if it is less than zero (iOS 8.0) in
  tableView:heightForRowAtIndexPath: of ABDViewController.
- Add UITableViewCell+IOS8DetailCellFix.m to fix the detail label display
  problem on iOS 8.
- Update the tools version in Main.storyboard.
- Move Authenticate Reader to the last section in Main.storyboard.
- Remove the checking of ACR3901U-S1 in tableView:didSelectRowAtIndexPath: of
  ABDViewController.
- Add Use Default Key to Main.storyboard.
- Use the default key in tableView:didSelectRowAtIndexPath: of
  ABDViewController.
- Add About BTDemo to Main.storyboard.
- Show the version information in tableView:didSelectRowAtIndexPath: of
  ABDViewController.
- Update the tools version in Main.storyboard.
- Add ABDTxPowerViewController.
- Add Tx Power to Main.storyboard.
- Add txPowerLabel to ABDViewController.
- Show Tx Power in prepareForSegue:sender: of ABDViewController.
- Update the version to 1.0.0 and the build to 4.

v1.0.0 Preview 3 (14/8/2014)
- Update systemVersion in Main.storyboard.
- Replace with ABTBluetoothReader:getDeviceInfoWithType: in
  prepareForSegue:sender: of ABDViewController.
- Cast _bluetoothReader to ABTAcr3901us1Reader in
  tableView:didSelectRowAtIndexPath: of ABDViewController.
- Remove unnecessary initialization in viewDidLoad of ABDViewController.
- Detect the reader using BluetoothReaderManager in ABDViewController.
- Add systemIdLabel and hardwareRevisionLabel to ABDDeviceInfoViewController.
- Replace the old delegate methods with
  bluetoothReader:didReturnDeviceInfo:type:error: of ABDViewController.
- Show the battery level for ACR1255U-J1.
- Enable/disable the polling for ACR1255U-J1.

v1.0.0 Preview 2 (18/7/2014)
- Add the missing init to _bluetoothReader in viewDidLoad of ABDViewController.
- Use <...> to import ACSBluetooth.h.
- Add centralManager:didDisconnectPeripheral:error: to ABDViewController.

v1.0.0 Preview 1 (30/5/2014)
- New release.



Demo (Mac OS X)

v1.0.0 Preview 4 (28/1/2016)
- Update to recommended settings in Xcode 7.2.
- Update the build to 4.

v1.0.0 Preview 3 (29/5/2015)
- Rename BTDemoMacOSX.xcodeproj to BTDemo.xcodeproj.
- Move Authenticate button to General tab in MainMenu.xib.
- Remove the checking of ACR3901U-S1 in authenticate: of ABDAppDelegate.
- Add setDefaultMasterKeyForAcr3901us1: to ABDAppDelegate.
- Add setDefaultMasterKeyForAcr1255uj1: to ABDAppDelegate.
- Disable connect and disconnect button in startScan: of ABDAppDelegate.
- Enable the buttons according to the reader type in
  bluetoothReader:didAttachPeripheral:error: of ABDAppDelegate.
- Add Tx Power to MainMenu.xib.
- Add txPowerPopUpButton to ABDAppDelegate.
- Add setTxPower: to ABDAppDelegate.
- Disable Tx Power pop up button in applicationDidFinishLaunching: of
  ABDAppDelegate.
- Disable Tx Power pop up button in
  centralManager:didDisconnectPeripheral:error: of ABDAppDelegate.
- Enable Tx Power pop up button in bluetoothReader:didAttachPeripheral:error: of
  ABDAppDelegate.
- Update the version to 1.0.0 and the build to 3.

v1.0.0 Preview 2 (14/8/2014)
- Replace with ABTBluetoothReader:getDeviceInfoWithType: in getDeviceInfo: of
  ABDAppDelegate.
- Cast _bluetoothReader to ABTAcr3901us1Reader in authenticate: of
  ABDAppDelegate.
- Cast _bluetoothReader to ABTAcr3901us1Reader in getBatteryStatus: of
  ABDAppDelegate.
- Detect the reader using BluetoothReaderManager in ABDAppDelegate.
- Add systemIdTextField and hardwareRevisionTextField to ABDAppDelegate.
- Replace the old delegate methods with
  bluetoothReader:didReturnDeviceInfo:type:error: of ABDAppDelegate.
- Show the battery level for ACR1255U-J1.
- Enable/disable the polling for ACR1255U-J1.
- Add Clear button to clear the data in ABDAppDelegate.
- Clear the data in centralManager:didDisconnectPeripheral:error: of
  ABDAppDelegate.
- Remove control:textShouldEndEditing: of ABDAppDelegate.
- Clear the card status, the battery status and the battery level in
  applicationDidFinishLaunching: of ABDAppDelegate.

v1.0.0 Preview 1 (18/7/2014)
- New release.



File Contents
-------------

API Documentation:  ACSBluetooth\doc

iOS

Sample Application: BTDemo
Class Library:      BTDemo\ACSBluetooth

Mac OS X

Sample Application: MacOSX\BTDemo
Class Library:      MacOSX\BTDemo\ACSBluetooth
Mac App:            MacOSX\BTDemo.app



Support
-------

In case of problem, please contact ACS through:

Web Site: http://www.acs.com.hk/
E-mail: info@acs.com.hk
Tel: +852 2796 7873
Fax: +852 2796 1286



-------------------------------------------------------------------------------
Copyright (C) 2014-2016 Advanced Card Systems Ltd. All Rights Reserved.

No part of this reference manual may be reproduced or transmitted in any from
without the expressed, written permission of ACS.

Due to rapid change in technology, some of specifications mentioned in this
publication are subject to change without notice. Information furnished is
believed to be accurate and reliable. ACS assumes no responsibility for any
errors or omissions, which may appear in this document.

IOS is a trademark or registered trademark of Cisco in the U.S. and other
countries and is used under license.

iPhone is a trademark of Apple Inc.

Xcode is a trademark of Apple Inc.

Mac and OS X are trademarks of Apple Inc.
