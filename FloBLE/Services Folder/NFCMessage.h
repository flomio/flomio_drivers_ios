//
//  NFCMessage.h
//  
//
//  Created by John Bullard on 9/21/12.
//  Copyright (c) 2012 Flomio Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

// Message Length Boundaries
#define MIN_MESSAGE_LENGTH                   3   //todo change to 4
#define MAX_MESSAGE_LENGTH                   255

#define CORRECT_CRC_VALUE                    0

// Message Protocol
#define FLO_MESSAGE_OPCODE_POSITION          0
#define FLO_MESSAGE_LENGTH_POSITION          1
#define FLO_MESSAGE_SUB_OPCODE_POSITION      2
#define FLO_MESSAGE_ENABLE_POSITION          3

#define FLO_TAG_UID_DATA_POS                 3
#define FLO_BLOCK_RW_MSG_DATA_LENGTH_POS     4
#define FLO_BLOCK_RW_MSG_DATA_POS            5

#define FLO_MESSAGE_OPCODE_LENGTH            1
#define FLO_MESSAGE_LENGTH_LENGTH            1
#define FLO_MESSAGE_SUB_OPCODE_LENGTH        1
#define FLO_MESSAGE_ENABLE_LENGTH            1
#define FLO_MESSAGE_CRC_LENGTH               1

#define FLO_BLOCK_RW_MSG_DATA_LENGTH_LEN     1
#define FLO_BLOCK_RW_MSG_DATA_LEN            1

// Message Enable/Disable values
#define FLOMIO_DISABLE                       0
#define FLOMIO_ENABLE                        1

// Tag Formatting
#define NDEF_MESSAGE_HEADER                  0x03

//Flomio Accessory-Client Message Opcodes
typedef enum
{
    FLOMIO_STATUS_OP = 1,               // 1
    FLOMIO_PROTO_ENABLE_OP,             // 2
    FLOMIO_POLLING_ENABLE_OP,           // 3
    FLOMIO_POLLING_RATE_OP,             // 4
    FLOMIO_TAG_READ_OP,                 // 5
    FLOMIO_ACK_ENABLE_OP,               // 6
    FLOMIO_STANDALONE_OP,               // 7
    FLOMIO_STANDALONE_TIMEOUT_OP,       // 8  TODO: Timeout needs to be implemented
    FLOMIO_DUMP_LOG_OP,                 // 9  TODO: Dump log needs to be implemented
    FLOMIO_LED_CONTROL_OP,              // 10 
    FLOMIO_TI_HOST_COMMAND_OP,          // 11
    FLOMIO_COMMUNICATION_CONFIG_OP,     // 12
    FLOMIO_PING_OP,                     // 13
    FLOMIO_OPERATION_MODE_OP,           // 14
    FLOMIO_BLOCK_READ_WRITE_OP,         // 15
    FLOMIO_TAG_WRITE_OP,				// 16
    FLOMIO_SNIFFER_CONFIG_OP,           // 17
    FLOMIO_DISCONNECT_OP                // 18
} flomio_opcode_t;

// FLOMIO_TAG_READ_OP sub opcode indicating tag type (most significant nibble)
typedef enum
{
    UNKNOWN_TAG_TYPE,
    NFC_FORUM_TYPE_1,	//NFC-A, Topaz
    NFC_FORUM_TYPE_2,	//NFC-A
    NFC_FORUM_TYPE_3,	//NFC-F
    NFC_FORUM_TYPE_4,	//NFC-A or NFC-B
    MIFARE_CLASSIC,		//NFC-A
    TYPE_V				//15693
} nfc_tag_types_t;

// FLOMIO_TAG_READ_OP sub opcode indicating UID length (least significant nibble)
typedef enum
{    
    FLOMIO_UID_ONLY = 0,                // UID only. Length varies
    FLOMIO_ALL_MEM_UID_LEN_FOUR,		// All memory including four byte UID
    FLOMIO_ALL_MEM_UID_LEN_SEVEN,		// All memory including seven byte UID
    FLOMIO_ALL_MEM_UID_LEN_EIGHT,		// All memory including eight byte UID (15693)
    FLOMIO_ALL_MEM_UID_LEN_TEN,			// All memory including ten byte UID
} flomio_tag_uid_opcodes_t;


//Flomio Status Sub-Opcode
typedef enum
{
    FLOMIO_STATUS_ALL = 0,
    FLOMIO_STATUS_HW_REV,
    FLOMIO_STATUS_SW_REV,
    FLOMIO_STATUS_BATTERY,
    FLOMIO_STATUS_SNIFFTHRESH,
    FLOMIO_STATUS_SNIFFCALIB
} flomio_status_opcodes_t;

//Battery Status
typedef enum
{
	FLOMIO_BATTERY_GOOD = 0,
	FLOMIO_BATTERY_LOW
}flomio_battery_state_t;

//Flomio NFC Protocols
typedef enum
{
    FLOMIO_PROTO_14443A = 0,
    FLOMIO_PROTO_14443B,
    FLOMIO_PROTO_15693,
    FLOMIO_PROTO_FELICA
} flomio_proto_opcodes_t;

//Flomio ACK responses
typedef enum
{
    FLOMIO_ACK_BAD = 0x80,
    FLOMIO_ACK_GOOD
} flomio_ack_responses_t;

//Polling Increment
#define FLOMIO_POLLING_RATE  25  //25 ms increments

//Flomio Log options
typedef enum
{
    FLOMIO_LOG_ALL = 0
} flomio_log_opcodes_t;

//Flomio LED Control definitions
typedef enum
{
    FLOMIO_LED_IDLE = 0,
    FLOMIO_LED_ON_SCAN,
    FLOMIO_LED_VALIDATION,
    FLOMIO_LED_COMM_ACTIVITY
} flomio_led_activity_t;

typedef enum
{
    FLOMIO_LED_1 = 1,
    FLOMIO_LED_2,
    FLOMIO_LED_3
} flomio_led_select_t;

typedef enum
{
    FLOMIO_LED_BLINK = 0,
    FLOMIO_LED_HEARTBEAT,
    FLOMIO_LED_PULSE
} flomio_led_action_t;

typedef struct
{
    flomio_led_activity_t led_activity;
    flomio_led_select_t   led_select;
    flomio_led_action_t   led_action;
    UInt8                 led_rate;
}flomio_led_config_t;

//Communications Config Sub-Opcode
typedef enum
{
    FLOMIO_BYTE_DELAY = 0,
    FLOMIO_PING_CONFIG
} flomio_comm_config_t;

//Ping/Pong Sub-Opcodes
typedef enum
{
    FLOMIO_PING = 0,
    FLOMIO_PONG,
    FLOMIO_PONG_LOW_POWER_ERROR,
    FLOMIO_PONG_CALIBRATION_ERROR,
} flomio_ping_pong_t;

//FLOMIO_OPERATION_MODE_OP Sub-Opcodes 
typedef enum
{
    FLOMIO_OP_MODE_READ_UID = 0,         // Send host UID only
    FLOMIO_OP_MODE_READ_ALL_MEMORY,      // Send host ALL BLOCKS (UID, OTP, CC, TLV, DATA, etc)
    FLOMIO_OP_MODE_WRITE_CURRENT,        // Write data to tag
    FLOMIO_OP_MODE_WRITE_PREVIOUS,       // Send UID. Wait for read or write command
    FLOMIO_OP_MODE_READ_UID_NDEF         // Send host UID + NDEF Message
} flomio_operation_modes_t;

//Block Read/Write Sub-Opcodes
typedef enum 
{
    FLOMIO_READ_BLOCK = 0,
    FLOMIO_WRITE_BLOCK,
    FLOMIO_WRITE_CONTINUOUS
} flomio_block_read_write_t;

// FLOMIO_TAG_WRITE_OP subopcodes
typedef enum
{
	FLOMIO_TAG_WRITE_STATUS_SUCCEEDED,
	FLOMIO_TAG_WRITE_STATUS_FAIL_TAG_UNSUPPORTED,
	FLOMIO_TAG_WRITE_STATUS_FAIL_TAG_READ_ONLY,
	FLOMIO_TAG_WRITE_STATUS_FAIL_TAG_NOT_ENOUGH_MEM,
    FLOMIO_TAG_WRITE_STATUS_FAIL_TAG_NOT_NDEF_FORMATTED,
	FLOMIO_TAG_WRITE_STATUS_FAIL_UNKOWN = 0xFF
} flomio_tag_write_status_opcodes_t;

// FLOMIO_SNIFFER_CONFIG_OP subopcodes
typedef enum
{
    FLOMIO_INCREMENT_THRESHOLD = 0,
    FLOMIO_DECREMENT_THRESHOLD,
    FLOMIO_RESET_THRESHOLD,
    FLOMIO_SET_MAX_THRESHOLD
} flomio_sniffer_config_opcodes_t;

// FLOMIO status codes for bubbling up to delegate
typedef enum
{
    FLOMIO_STATUS_PING_CALIBRATION_ERROR   = -6,
    FLOMIO_STATUS_PING_LOW_POWER_ERROR     = -5,
    FLOMIO_STATUS_MESSAGE_CORRUPT_ERROR    = -4,
    FLOMIO_STATUS_VOLUME_LOW_ERROR         = -3,
    FLOMIO_STATUS_NACK_ERROR               = -2,
    FLOMIO_STATUS_GENERIC_ERROR            = -1,
    FLOMIO_STATUS_PING_RECIEVED            = 1,
    FLOMIO_STATUS_ACK_RECIEVED             = 2,
    FLOMIO_STATUS_VOLUME_OK                = 3,
    FLOMIO_STATUS_READER_CONNECTED        = 4,
    FLOMIO_STATUS_READER_DISCONNECTED     = 5,
} flomio_nfc_adapter_status_codes_t;

// FloBLE LED Status States
typedef enum {
    LED_POWER_UP,
    LED_SLOW_SNIFF,
    LED_ADVERTISING,
    LED_FAST_SNIFF,
    LED_SCANNING_TAG,
    LED_VERIFING_TAG,
    LED_TAG_SUCCESS,
    LED_TAG_ERROR,
    LED_OFF
} ledStatus_t;

// FloJack protocol messages {opcode, length, data[] } - Used for messages that don't have 
const static UInt8 status_hw_rev_msg[] =         {FLOMIO_STATUS_OP,0x04,FLOMIO_STATUS_HW_REV,0x04};
const static UInt8 status_sw_rev_msg[] =         {FLOMIO_STATUS_OP,0x04,FLOMIO_STATUS_SW_REV,0x07};
const static UInt8 status_sniffthresh_msg[] =    {FLOMIO_STATUS_OP,0x04,FLOMIO_STATUS_SNIFFTHRESH,0x01};
const static UInt8 status_sniffcalib_msg[] =     {FLOMIO_STATUS_OP,0x04,FLOMIO_STATUS_SNIFFCALIB,0x01};


@interface FJMessage : NSObject

@property (nonatomic, strong)   NSData    *bytes;
@property (nonatomic)           UInt8     opcode;
@property (nonatomic)           UInt8     length;
@property (nonatomic)           UInt8     subOpcode;
@property (nonatomic)           UInt8     subOpcodeMSN;
@property (nonatomic)           UInt8     subOpcodeLSN;
@property (nonatomic)           BOOL      enable;
@property (nonatomic, strong)   NSData    *offset;
@property (nonatomic, strong)   NSData    *data;
@property (nonatomic)           UInt8     *crc;
@property (nonatomic, strong)   NSString  *name;

- (id)init;
- (id)initWithBytes:(UInt8 *)theBytes;
- (id)initWithData:(NSData *)theData;
- (id)initWithMessageParameters:(UInt8)opcode andSubOpcode:(UInt8)subOpcode andData:(NSData *)data;

+ (NSString*)formatStatusCodesToString:(flomio_nfc_adapter_status_codes_t)statusCode;
+ (NSString*)formatTagWriteStatusToString:(flomio_tag_write_status_opcodes_t)statusCode;
+ (UInt8)getMessageSubOpcode:(NSData *)theMessage;

@end
