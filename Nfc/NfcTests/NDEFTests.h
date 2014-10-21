//
//  NDEFTests.h
//  Flomio
//
//  Created by John Bullard on 9/21/12.
//  Copyright (c) 2012 Flomio Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "FlomioMessage.h"
#import "NDEFMessage.h"
#import "NDEFRecord.h"
#import "Tag.h"

/*
 Collection of unit tests used to test NDEF Record and Message parsing. 
 
 Example of an NDEF Record:
     
     // Record 0
     [0] Flag Byte
     1001 0001 (0x91)
     |||| ||
     |||| ||---> TNF = 001      // TNF_WELL_KNOWN = 0x01;
     |||| |----> IL = 0
     ||||
     ||||------>	SR = 1 		// short record
     |||------->	CF = 0
     ||-------->	ME = 0
     |--------->	MB = 1 		// message begin
     
     [1] Type Length
     0000 0001  (1)
     
     [2] Payload Length
     0000 1100 (12) 	// "(http://)tags.to/ntl", note this only applies to chunk 0
     
     [3] Type
     0101 0101 (85) 	// RTD_URI = {0x55};   // "U"s
     
     [4..15] Payload
     0000 0011 (3)	// "http://" 0x03
     116, 97, 103, 115, 46, 116, 111, 47, 110, 116, 108
     
     // Record 1
     [16] Flag Byte
     0101 0010 (82) (0x52)
     |||| ||
     |||| ||---> TNF = 010 	// TNF_MIME_MEDIA = 0x02;
     |||| |----> IL = 0
     ||||
     ||||------>	SR = 1 		// short record
     |||------->	CF = 0
     ||-------->	ME = 1 		// message end
     |--------->	MB = 0
     
     [17] Type Length
     0000 0011 (3) (0x03)
     
     [18] Payload Length
     0010 1011 (43) (0x2b)
     
     [19..21] Type
     0110 1110 (110) (0x6e)	// ntl
     0111 1000 (116) (0x74)
     0110 1100 (118) (0x6c)
     
     [22..64] Payload
     2, 101, 110, 90, 58, 56, 58, 84, 97, 115, 107, 32, 56, 59, 112, 58, 53, 54, 49, 51, 48, 57, 57, 51, 51, 52, 59, 111, 58, 53, 54, 49, 51, 48, 57, 57, 51, 51, 52, 58, 121, 101, 115
 */
@interface NDEFTests : SenTestCase {
    NSArray *_ndefRecords;
}

@end
