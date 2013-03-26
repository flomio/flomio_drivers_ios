//
//  FJMessage.h
//  FloJack
//
//  Created by John Bullard on 9/21/12.
//  Copyright (c) 2012 Flomio Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

// Message Length Boundaries
#define MIN_MESSAGE_LENGTH                       3   //todo change to 4
#define MAX_MESSAGE_LENGTH                       255

#define CORRECT_CRC_VALUE                        0   

// Message Protocol
#define FLOJACK_MESSAGE_OPCODE_POSITION          0
#define FLOJACK_MESSAGE_LENGTH_POSITION          1
#define FLOJACK_MESSAGE_SUB_OPCODE_POSITION      2
#define FLOJACK_MESSAGE_ENABLE_POSITION          3

#define FJ_TAG_UID_DATA_POS                      3
#define FJ_BLOCK_RW_MSG_DATA_LENGTH_POS          4
#define FJ_BLOCK_RW_MSG_DATA_POS                 5

#define FLOJACK_MESSAGE_OPCODE_LENGTH            1
#define FLOJACK_MESSAGE_LENGTH_LENGTH            1
#define FLOJACK_MESSAGE_SUB_OPCODE_LENGTH        1
#define FLOJACK_MESSAGE_ENABLE_LENGTH            1
#define FLOJACK_MESSAGE_CRC_LENGTH               1

#define FJ_BLOCK_RW_MSG_DATA_LENGTH_LEN          1
#define FJ_BLOCK_RW_MSG_DATA_LEN                 1

// Message Enable/Disable values
#define FLOMIO_DISABLE                           0
#define FLOMIO_ENABLE                            1

// Tag Formatting
#define NDEF_MESSAGE_HEADER                      0x03

// FloJack protocol messages {opcode, length, data[] }
const static UInt8 ack_disable_msg[] =                  {0x06,0x04,0x00,0x02};

const static UInt8 ack_enable_msg[] =                   {0x06,0x04,0x01,0x03};

const static UInt8 comm_set_ping_disable[] =            {0x0C,0x05,0x01,0x00,0x08};

const static UInt8 comm_set_ping_enable[] =             {0x0C,0x05,0x01,0x00,0x09};

const static UInt8 dump_log_all_msg[] =                 {0x09,0x04,0x00,0x0D};

const static UInt8 flomio_bad_ack[] =                   {0x06, 0x04, 0x80, 0x82};

const static UInt8 flomio_good_ack[] =                  {0x06, 0x04, 0x81, 0x83};

const static UInt8 inter_byte_delay_ipad3_msg[] =       {0x0C, 0x05, 0x00, 0x0C, 0x05};

const static UInt8 inter_byte_delay_ipad2_msg[] =       {0x0C, 0x05, 0x00, 0x0C, 0x05};
/*
 TODO: iPad Mini Testing
 0x05 = (0x0C ^ 0x05 ^ 0x00)     // CRC calc
 0x0C, 0x05, 0x00, 0x06, 0x0F
 0x0C, 0x05, 0x00, 0x0B, 0x02
 0x0C, 0x05, 0x00, 0x0C, 0x05    // ipad 2
 0x0C, 0x05, 0x00, 0x50, 0x59    // 3gs
 0x0C, 0x05, 0x00, 0x80, 0x89    // flojack default
 0x0C, 0x05, 0x00, 0xFF, 0xF6
*/
const static UInt8 inter_byte_delay_ipad_mini_msg[] =   {0x0C, 0x05, 0x00, 0x50, 0x59 };

const static UInt8 inter_byte_delay_iphone4s_msg[] =    {0x0C, 0x05, 0x00, 0x20, 0x29};

const static UInt8 inter_byte_delay_iphone4_msg[] =     {0x0C, 0x05, 0x00, 0x20, 0x29};

const static UInt8 inter_byte_delay_iphone3gs_msg[] =   {0x0C, 0x05, 0x00, 0x50, 0x59};

const static UInt8 inter_byte_delay_default_msg[] =     {0x0C, 0x05, 0x50, 0x59};

const static UInt8 keep_alive_time_infinite_msg[] =     {0x08,0x04,0x00,0x0C};

const static UInt8 keep_alive_time_one_min_msg[] =      {0x08,0x04,0x01,0x0D};

const static UInt8 ping_command[] =                     {0x0D, 0x04, 0x00, 0x09};

const static UInt8 pong_command[] =                     {0x0D, 0x04, 0x01, 0x08};

const static UInt8 polling_disable_msg[] =              {0x03,0x04,0x00,0x07};

const static UInt8 polling_enable_msg[] =               {0x03,0x04,0x01,0x06};

const static UInt8 polling_frequency_1000ms_msg[] =     {0x04,0x04,0x28,0x28};

const static UInt8 polling_frequency_3000ms_msg[] =     {0x04,0x04,0x78,0x78};

const static UInt8 protocol_14443A_msg[] =              {0x02,0x05,0x00,0x01,0x06};

const static UInt8 protocol_14443A_off_msg[] =          {0x02,0x05,0x00,0x00,0x07};

const static UInt8 protocol_14443B_msg[] =              {0x02,0x05,0x01,0x01,0x07};

const static UInt8 protocol_14443B_off_msg[] =          {0x02,0x05,0x01,0x00,0x06};

const static UInt8 protocol_15693_msg[] =               {0x02,0x05,0x02,0x01,0x04};

const static UInt8 protocol_15693_off_msg[] =           {0x02,0x05,0x02,0x00,0x05};

const static UInt8 protocol_felica_msg[] =              {0x02,0x05,0x03,0x01,0x05};

const static UInt8 protocol_felica_off_msg[] =          {0x02,0x05,0x03,0x00,0x04};

const static UInt8 standalone_disable_msg[] =           {0x07,0x04,0x00,0x03};

const static UInt8 standalone_enable_msg[] =            {0x07,0x04,0x01,0x02};

const static UInt8 status_msg[] =                       {0x01,0x04,0x00,0x05};

const static UInt8 status_hw_rev_msg[] =                {0x01,0x04,0x01,0x04};

const static UInt8 status_sw_rev_msg[] =                {0x01,0x04,0x02,0x07};

const static UInt8 ti_host_command_led_on_msg[] =       {0x0B,0x09,0x06,0x06,0x00,0x03,0x04,0xF3,0xF6};

const static UInt8 ti_host_command_led_off_msg[] =      {0x0B,0x09,0x06,0x06,0x00,0x03,0x04,0xF4,0xF1};

const static UInt8 op_mode_uid_only[] =                 {0x0E,0x05,0x00,0x01,0x0A};

const static UInt8 op_mode_uid_only_no_redundancy[] =   {0x0E,0x05,0x00,0x00,0x0B};

const static UInt8 op_mode_read_memory_only[] =         {0x0E,0x04,0x01,0x0B};

const static UInt8 op_mode_write_only[] =               {0x0E,0x05,0x02,0x01,0x08};

const static UInt8 op_mode_write_only_no_override[] =   {0x0E,0x05,0x02,0x00,0x09};

const static UInt8 op_mode_read_write[] =               {0x0E,0x04,0x03,0x09};


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
    FLOMIO_STANDALONE_TIMEOUT_OP,       // 8
    FLOMIO_DUMP_LOG_OP,                 // 9
    FLOMIO_LED_CONTROL_OP,              // 10
    FLOMIO_TI_HOST_COMMAND_OP,          // 11
    FLOMIO_COMMUNICATION_CONFIG_OP,     // 12
    FLOMIO_PING_OP,                     // 13
    FLOMIO_OPERATION_MODE_OP,           // 14
    FLOMIO_BLOCK_READ_WRITE_OP,         // 15
    FLOMIO_TAG_WRITE_OP,				// 16
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
    FLOMIO_ALL_MEM_UID_LEN_TEN,			// All memory including ten byte UID
} flomio_tag_uid_opcodes_t;


//Flomio Status Sub-Opcode
typedef enum
{
    FLOMIO_STATUS_ALL = 0,
    FLOMIO_STATUS_HW_REV,
    FLOMIO_STATUS_SW_REV,
    FLOMIO_STATUS_BATTERY
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
    FLOMIO_PONG
} flomio_ping_pong_t;

//FLOMIO_OPERATION_MODE_OP Sub-Opcodes 
typedef enum
{
    FLOMIO_OP_MODE_READ_UID = 0,        // Send host UID only
    FLOMIO_OP_MODE_READ_ALL_MEMORY,     // Send host ALL BLOCKS (UID, OTP, CC, TLV, DATA, etc)
    FLOMIO_OP_MODE_WRITE_CURRENT,       // Write data to tag
    FLOMIO_OP_MODE_WRITE_PREVIOUS       // Send UID. Wait for read or write command
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

// FLOMIO status codes for bubbling up to delegate
typedef enum
{
	FLOMIO_STATUS_MESSAGE_CORRUPT_ERROR    = -4,
    FLOMIO_STATUS_VOLUME_LOW_ERROR         = -3,
    FLOMIO_STATUS_NACK_ERROR               = -2,
    FLOMIO_STATUS_GENERIC_ERROR            = -1,
    FLOMIO_STATUS_PING_RECIEVED            = 1,
    FLOMIO_STATUS_ACK_RECIEVED             = 2,
    FLOMIO_STATUS_VOLUME_OK                = 3,
    FLOMIO_STATUS_FLOJACK_CONNECTED        = 4,
    FLOMIO_STATUS_FLOJACK_DISCONNECTED     = 5,
} flomio_nfc_adapter_status_codes_t;

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

+ (UInt8)getMessageSubOpcode:(NSData *)theMessage;

@end
