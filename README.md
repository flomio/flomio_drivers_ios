FloJack Objective-C NFC Client Library (alpha)
================================================

A client library for use with the FloJack NFC reader. 


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


TODO
---------------
This library is functional but actively under development. Much will be changing. 
- Finish implementing NDEF read/write 
- Begin implementing LLCP arhcitecture
- Begin implementing SNEP atop LLCP


Contributing
---------------
Interested in bringing NFC to iOS? Get in touch info at flomio dot com.