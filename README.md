FloJack Objective-C NFC Client Library (alpha)
================================================

A client library for use with the FloJack NFC reader.

Please help us make this a reality and contribute to our Kickstarter campaign: 
http://www.kickstarter.com/projects/flomio/flojack-nfc-for-ipad-and-iphone/ 


Installing
----------------
Choose one of the following options:

- Copy all the files under the FloJack group into your app.
- Include FloJack as a subproject and include libFloJack.a

  If you do this, you must add -ObjC to your "other linker flags" option


Import ``"FJNFCAdapter.h"``

Framework Dependencies
----------------
Your app must be linked against the following frameworks

- AudioToolbox.framework
- CoreAudio.framework
- MobileCoreServices.framework
- QuartzCore.framework


API
---
The classes you care about

``FJNFCAdapterDelegate``

Implement these guys:
  
    @protocol SRWebSocketDelegate <NSObject>

    @required
    
    - (void)nfcAdapter:(FJNFCAdapter *)nfcAdapter didScanTag:(FJNFCTag *)theNfcTag;
    - (BOOL)nfcAdapter:(id)sender shouldWriteTagwithData:(NSData *)theData;
    - (BOOL)nfcAdapter:(id)sender shouldSendMessage:(NSData *)theMessage;

    @optional

    - (void)nfcAdapter:(FJNFCAdapter *)nfcAdapter didReceiveFirmwareVersion:(NSString*)theVersionNumber;
    - (void)nfcAdapter:(FJNFCAdapter *)nfcAdapter didReceiveHardwareVersion:(NSString*)theVersionNumber;
    - (void)nfcAdapterDidDetectFloJackConnected:(FJNFCAdapter *)nfcAdapter;
    - (void)nfcAdapterDidDetectFloJackDisconnected:(FJNFCAdapter *)nfcAdapter;

    @end


Example
---------------
See FloJackExample target app included in this project.


TODO
---------------
This library is actively under development, much will be changing.
 
- Finish implementing NDEF read/write 
- Begin implementing LLCP arhcitecture
- Begin implementing SNEP atop LLCP


Contributing
---------------
Interested in bringing NFC to iOS? Get in touch info at flomio dot com.