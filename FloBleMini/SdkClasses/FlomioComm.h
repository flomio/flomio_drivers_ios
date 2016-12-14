//
//  FlomioComm.h
//  SDK
//
//  Created by Richard Grundy on 12/10/16.
//  Copyright (c) 2012 Flomio Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/*******************************************************************************
 * CONSTANTS
 */
// Message Length Boundaries
#define FLOMIO_MIN_MESSAGE_LENGTH               3
#define FLOMIO_MAX_MESSAGE_LENGTH               256

// Message Protocol
#define FLOMIO_MESSAGE_OPCODE_POSITION          0
#define FLOMIO_MESSAGE_SUBOPCODE_POSITION       1
#define FLOMIO_MESSAGE_LENGTH_POSITION          2
#define FLOMIO_MESSAGE_PAYLOAD_POSITION         3

/*******************************************************************************
 * TYPEDEFS
 */
// Flomio Comm Main Opcodes
typedef enum
{
    FLOMIO_INFO_OP = 0xFB,			// 251
    FLOMIO_MISC_OP = 0xFC,			// 252
    FLOMIO_BLE_OP = 0xFD,		    // 253
    FLOMIO_NFC_OP = 0xFE        	// 254
} flomio_opcode_t;

// Flomio Info subopcodes
typedef enum
{
    FLOMIO_INFO_HW_REV = 0,
    FLOMIO_INFO_SW_REV,
    FLOMIO_STATUS_BATTERY,
    FLOMIO_STATUS_SNIFFTHRESH,
    FLOMIO_STATUS_SNIFFCALIB
} flomio_info_opcodes_t;

// Flomio Sniffer subopcodes
typedef enum
{
    FLOMIO_SNIFF_CONFIG_INCREMENT_THRESHOLD = 0,
    FLOMIO_SNIFF_CONFIG_DECREMENT_THRESHOLD,
    FLOMIO_SNIFF_CONFIG_RESET_THRESHOLD,
    FLOMIO_SNIFF_CONFIG_SET_MAX_THRESHOLD
} flomio_sniff_config_opcodes_t;

// FloBLE Misc subopcodes
typedef enum {
    WRISTBAND_HAPTIC_EVT,
    WRISTBAND_SW1_EVT,
    WRISTBAND_SW2_EVT,
    WRISTBAND_SW3_EVT,
    WRISTBAND_SW4_EVT,
    WRISTBAND_ORIENTATION_EVT,
    WRISTBAND_MOTION_EVT,
    WRISTBAND_WIRELESS_CHARGING_EVT,
} wristbandStatus_t;

// Flomio BLE subopcodes
typedef enum
{
    FLOMIO_BLE_DISCONNECT_OP = 0,
} flomio_ble_opcodes_t;

// Flomio NFC subopcodes
typedef enum
{
    // General NFC commands
    COMM_START 			= 0x80,
    COMM_END 			= 0x81,
    NFC_TEST_CONFIG 	= 0x82,
    TRF_SETTINGS  		= 0x83,
    
    // P2P Commands
    P2P_START_CMD 		= 0xA0,
    P2P_STOP_CMD 		= 0xA1,
    P2P_PUSH_PAYLOAD 	= 0xA2,
    
    // CE Commands
    CE_START_CMD 		= 0xC0,
    CE_STOP_CMD 		= 0xC1,
    CE_NDEF_CONFIG 		= 0xC2,
    
    // RW Commands
    RW_START_CMD 		= 0xE0,
    RW_STOP_CMD 		= 0xE1,
    RW_FORMAT_PAYLOAD 	= 0xE2,
    RW_WRITE_TAG 		= 0xE3
    
}tNFCControllerCommands;

// States for all NFC protocol state machines
typedef enum {
    NFC_STATE_IDLE = 0,
    NFC_TARGET_WAIT_FOR_ACTIVATION,
    NFC_PROTOCOL_ACTIVATION,
    NFC_PARAMETER_SELECTION,
    NFC_DATA_EXCHANGE_PROTOCOL,
    NFC_MIFARE_DATA_EXCHANGE_PROTOCOL,
    NFC_DEACTIVATION,
    NFC_DISABLED
} tNfcState;

typedef union {
    struct
    {
        uint8_t bNfcModePoll 	: 1;
        uint8_t bNfcModeListen 	: 1;
        uint8_t bReserved		: 1;
    }bits;
    uint8_t ui8Byte;
} tNfcMode;

@interface FlomioComm : NSObject

@property (nonatomic, strong)   NSData    *bytes;
@property (nonatomic, strong)   UInt8     opcode;
@property (nonatomic, strong)   UInt8     subOpcode;
@property (nonatomic, strong)   UInt8     length;
@property (nonatomic, strong)   NSData    *data;

- (id)init;
- (id)initWithBytes:(UInt8 *)theBytes;
- (id)initWithData:(NSData *)theData;
- (id)initWithMessageParameters:(UInt8)opcode andSubOpcode:(UInt8)subOpcode andData:(NSData *)data;

+ (UInt8)getMessageSubOpcode:(NSData *)theMessage;

@end
