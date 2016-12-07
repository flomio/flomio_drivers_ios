//
//  FlomioComm.h
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
#define FLO_MESSAGE_SUB_OPCODE_POSITION      1
#define FLO_MESSAGE_LENGTH_POSITION          2
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
    FLOMIO_WRISTBAND_OP,                // 2
    FLOMIO_BLE_OP,                      // 3
    FLOMIO_NFC_OP = 0xFE                // 254
} flomio_opcode_t;

//Flomio Status Sub-Opcode
typedef enum
{
    FLOMIO_STATUS_HW_REV = 0,
    FLOMIO_STATUS_SW_REV,
    FLOMIO_STATUS_BATTERY,
    FLOMIO_STATUS_SNIFFTHRESH,
    FLOMIO_STATUS_SNIFFCALIB
} flomio_status_opcodes_t;

// FLOMIO_SNIFFER_CONFIG_OP subopcodes
typedef enum
{
    FLOMIO_INCREMENT_THRESHOLD = 0,
    FLOMIO_DECREMENT_THRESHOLD,
    FLOMIO_RESET_THRESHOLD,
    FLOMIO_SET_MAX_THRESHOLD
} flomio_sniffer_config_opcodes_t;

//Flomio ACK responses
typedef enum
{
    FLOMIO_ACK_BAD = 0x80,
    FLOMIO_ACK_GOOD
} flomio_ack_responses_t;

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

// FloBLE Wristband States
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

+ (UInt8)getMessageSubOpcode:(NSData *)theMessage;

@end
