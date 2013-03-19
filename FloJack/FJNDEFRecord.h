//
//  FJNDEFRecord.h
//  FloJack
//
//  Created by John Bullard on 9/21/12.
//  Copyright (c) 2012 Flomio Inc. All rights reserved.
//
//  NOTE:   This file is a port of Android.nfc.NdefRecord code found in the The Android Open Source Project.
//

#import <Foundation/Foundation.h>
#import "NSData+FJStringDisplay.h"
#import "FJNDEFMessage.h"

//    Indicates no type, id, or payload is associated with this NDEF Record.
//    Type, id and payload fields must all be empty to be a valid TNF_EMPTY
//    record.
static const UInt8 kTNFEmpty           = 0x00;

//    Indicates the type field uses the RTD type name format.
//    Use this TNF with RTD types such as RTD_TEXT, RTD_URI.
static const UInt8 kTNFWellKnown       = 0x01;

//    Indicates the type field contains a value that follows the media-type BNF
//    construct defined by RFC 2046.
static const UInt8 kTNFMimeMedia       = 0x02;

//    Indicates the type field contains a value that follows the absolute-URI
//    BNF construct defined by RFC 3986.
static const UInt8 kTNFAbsoluteUri     = 0x03;

//    Indicates the type field contains a value that follows the RTD external
//    name specification.
//    Note this TNF should not be used with RTD_TEXT or RTD_URI constants.
//    Those are well known RTD constants, not external RTD constants.
static const UInt8 kTNFExternalType    = 0x04;

//    Indicates the payload type is unknown.
//    This is similar to the "application/octet-stream" MIME type. The payload
//    type is not explicitly encoded within the NDEF Message.
//    The type field must be empty to be a valid TNF_UNKNOWN record.
static const UInt8 kTNFUnknown         = 0x05;

//    Indicates the payload is an intermediate or final chunk of a chunked
//    NDEF Record.
//    The payload type is specified in the first chunk, and subsequent chunks
//    must use TNF_UNCHANGED with an empty type field. TNF_UNCHANGED must not
//    be used in any other situation.
static const UInt8 kTNFUnchanged       = 0x06;

//    Reserved TNF type.
//    The NFC Forum NDEF Specification v1.0 suggests for NDEF parsers to treat this
//    value like TNF_UNKNOWN.
static const UInt8 kTNFReserved        = 0x07;

// RTD Text type. For use with TNF_WELL_KNOWN. // "T"
static NSData *kRTDText = nil;

// RTD URI type. For use with TNF_WELL_KNOWN.  // "U"
static NSData *kRTDURI = nil;

// RTD Smart Poster type. For use with TNF_WELL_KNOWN. // "Sp"
static NSData *kRTDSmartPost = nil; 

// RTD Alternative Carrier type. For use with TNF_WELL_KNOWN. // "ac"
static NSData *kRTDAlternativeCarrier = nil; 

// RTD Handover Carrier type. For use with TNF_WELL_KNOWN. // "Hc"
static NSData *kRTDHandoverCarrier = nil;

// RTD Handover Request type. For use with TNF_WELL_KNOWN. // "Hr"
static NSData *kRTDHandoverRequest = nil;

// RTD Handover Select type. For use with TNF_WELL_KNOWN. // "Hs"
static NSData *kRTDHandoverSelect = nil;

// NDEF flag mask: Message Begins
static const UInt8 kFlagMB = 0x80;

// NDEF flag mask: Message Ends
static const UInt8 kFlagME = 0x40;

// NDEF flag mask: Chunk Flag
static const UInt8 kFlagCF = 0x20;

// NDEF flag mask: Short Record
static const UInt8 kFlagSR = 0x10;

// NDEF flag mask: ID Length Present
static const UInt8 kFlagIL = 0x08;

// 10 MB NDEF record payload limit
static const long kMaxPayloadSize = 10 * (1 << 20);

/**
 NFC Forum "URI Record Type Definition"
 
 This is a mapping of "URI Identifier Codes" to URI string prefixes,
 per section 3.2.2 of the NFC Forum URI Record Type Definition document.
 */
static NSArray *kUriPrefixMap = nil;

// Represents a logical (unchunked) NDEF (NFC Data Exchange Format) record.
// An NDEF record always contains:
//
//   3-bit TNF (Type Name Format) field: Indicates how to interpret the type field
//   Variable length type: Describes the record format
//   Variable length ID: A unique identifier for the record
//   Variable length payload: The actual data payload
//
// The underlying record representation may be chunked across several NDEF records when the payload is large.
// This is an immutable data class.
//
@interface FJNDEFRecord : NSObject 

// Construct an NDEF Record. Validation is performed to make sure the header is valid, and that the id, type and payload sizes appear to be valid.
- (id)initWithTnf:(short)tnf andType:(NSData *)type andId:(NSData *)theId andPayload:(NSData *)payload;

// Construct an NDEF Record from raw bytes.
// Validation is performed to make sure the header is valid, and that the id, type and payload sizes appear to be valid.
// Definitive initializer.
- (id)initWithTnf:(short)tnf andType:(NSData *)type andId:(NSData *)theId andPayload:(NSData *)payload andFlags:(NSData *)flags;

// Returns a byte buffer representation of this NDEF record.
- (NSData *)asByteBuffer;

// Returns the URL from a TNF_WELL_KNOWN record (if applicable).
- (NSURL *)getUriFromPayload;

// Parses the byte message for one or more NDEF records.
+ (NSArray *)parseData:(NSData *)data andIgnoreMbMe:(BOOL)ignoreMbMe;

#pragma mark - Static helper methods
// Creates an NDEF record payload of well known type URI.
+ (FJNDEFRecord *)createURIWithURL:(NSURL *)url;
+ (FJNDEFRecord *)createURIWithString:(NSString *)uriString;

@property(nonatomic, readonly) short tnf;
@property(nonatomic, readonly) NSData *type;
@property(nonatomic, readonly) NSData *theId;
@property(nonatomic, readonly) NSData *payload;

@end
