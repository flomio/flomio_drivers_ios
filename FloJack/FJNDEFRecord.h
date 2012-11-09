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

// Creates an NDEF record of well known type URI.
- (FJNDEFRecord *)createUriRecordFromUri:(NSURL *)url;

- (FJNDEFRecord *)createUriRecordFromUriString:(NSString *)uriString;

// Parses the byte message for one or more NDEF records.
+ (NSArray *)parseData:(NSData *)data andIgnoreMbMe:(BOOL)ignoreMbMe;


@end
