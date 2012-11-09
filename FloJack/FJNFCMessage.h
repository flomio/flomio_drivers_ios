//
//  FJNFCMessage.h
//  FloJack
//
//  Created by John Bullard on 9/21/12.
//  Copyright (c) 2012 Flomio Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

// Message Length Boundaries
#define MIN_MESSAGE_LENGTH                       3   //todo change to 4
#define MAX_MESSAGE_LENGTH                       20

#define CORRECT_CRC_VALUE                        0   

// Message Protocol
#define FLOJACK_MESSAGE_OPCODE_POSITION          0
#define FLOJACK_MESSAGE_LENGTH_POSITION          1
#define FLOJACK_MESSAGE_SUB_OPCODE_POSITION      2
#define FLOJACK_MESSAGE_ENABLE_POSITION          3

#define FLOJACK_MESSAGE_OPCODE_LENGTH            1
#define FLOJACK_MESSAGE_LENGTH_LENGTH            1
#define FLOJACK_MESSAGE_SUB_OPCODE_LENGTH        1
#define FLOJACK_MESSAGE_ENABLE_LENGTH            1

// Message Enable/Disable values
#define FLOMIO_DISABLE                           0
#define FLOMIO_ENABLE                            1

// FloJack protocol messages {opcode, length, data[] }
static const UInt8 ack_disable_msg[] =                  {0x06,0x04,0x00,0x02};

static const UInt8 ack_enable_msg[] =                   {0x06,0x04,0x01,0x03};

const static UInt8 comm_set_ping_disable[] =            {0x0C,0x05,0x01,0x00,0x08};

const static UInt8 comm_set_ping_enable[] =             {0x0C,0x05,0x01,0x00,0x09};

static const UInt8 dump_log_all_msg[] =                 {0x09,0x04,0x00,0x0D};

const static UInt8 flomio_bad_ack[] =                   {0x06, 0x04, 0x80, 0x82};

const static UInt8 flomio_good_ack[] =                  {0x06, 0x04, 0x81, 0x83};

const static UInt8 inter_byte_delay_ipad3_msg[] =       {0x0C, 0x05, 0x00, 0x0C, 0x05};

const static UInt8 inter_byte_delay_ipad2_msg[] =       {0x0C, 0x05, 0x00, 0x0C, 0x05};

const static UInt8 inter_byte_delay_iphone4s_msg[] =    {0x0C, 0x05, 0x00, 0x20, 0x29};

const static UInt8 inter_byte_delay_iphone4_msg[] =     {0x0C, 0x05, 0x00, 0x20, 0x29};

const static UInt8 inter_byte_delay_iphone3gs_msg[] =   {0x0C, 0x05, 0x00, 0x50, 0x59};

const static UInt8 inter_byte_delay_default_msg[] =     {0x0C, 0x05, 0x50, 0x59};

static const UInt8 keep_alive_time_infinite_msg[] =     {0x08,0x04,0x00,0x0C};

static const UInt8 keep_alive_time_one_min_msg[] =      {0x08,0x04,0x01,0x0D};

const static UInt8 ping_command[] =                     {0x0D, 0x04, 0x00, 0x09};

const static UInt8 pong_command[] =                     {0x0D, 0x04, 0x01, 0x08};

static const UInt8 polling_disable_msg[] =              {0x03,0x04,0x00,0x07};

static const UInt8 polling_enable_msg[] =               {0x03,0x04,0x01,0x06};

static const UInt8 polling_frequency_1000ms_msg[] =     {0x04,0x04,0x28,0x28};

static const UInt8 polling_frequency_3000ms_msg[] =     {0x04,0x04,0x78,0x78};

static const UInt8 protocol_14443A_msg[] =              {0x02,0x05,0x00,0x01,0x06};

static const UInt8 protocol_14443A_off_msg[] =          {0x02,0x05,0x00,0x00,0x07};

static const UInt8 protocol_14443B_msg[] =              {0x02,0x05,0x01,0x01,0x07};

static const UInt8 protocol_14443B_off_msg[] =          {0x02,0x05,0x01,0x00,0x06};

static const UInt8 protocol_15693_msg[] =               {0x02,0x05,0x02,0x01,0x04};

static const UInt8 protocol_15693_off_msg[] =           {0x02,0x05,0x02,0x00,0x05};

static const UInt8 protocol_felica_msg[] =              {0x02,0x05,0x03,0x01,0x05};

static const UInt8 protocol_felica_off_msg[] =          {0x02,0x05,0x03,0x00,0x04};

static const UInt8 standalone_disable_msg[] =           {0x07,0x04,0x00,0x03};

static const UInt8 standalone_enable_msg[] =            {0x07,0x04,0x01,0x02};

static const UInt8 status_msg[] =                       {0x01,0x04,0x00,0x05};

static const UInt8 status_hw_rev_msg[] =                {0x01,0x04,0x01,0x04};

static const UInt8 status_sw_rev_msg[] =                {0x01,0x04,0x02,0x07};

static const UInt8 ti_host_command_led_on_msg[] =       {0x0B,0x09,0x06,0x06,0x00,0x03,0x04,0xF3,0xF6};

static const UInt8 ti_host_command_led_off_msg[] =      {0x0B,0x09,0x06,0x06,0x00,0x03,0x04,0xF4,0xF1};

//Register write
static const UInt8 test_register_write_msg[] =          {0x0B, 0x0F ,0x06, 0x0C, 0x00, 0x03, 0x04, 0x10, 0x00, 0x21, 0x01, 0x09, 0x00, 0x00, 0x30};

//AGC toggle
static const UInt8 test_agc_toggle_msg[] =              {0x0B, 0x0C ,0x06, 0x09, 0x00, 0x03, 0x04, 0xF0, 0x00, 0x00, 0x00, 0xFF};

//AM/PM toggle
static const UInt8 test_am_pm_toggle_msg[] =            {0x0B, 0x0C ,0x06, 0x09, 0x00, 0x03, 0x04, 0xF1, 0xFF, 0x00, 0x00, 0x01};

//14443A Request
static const UInt8 test_14443a_request_msg[] =          {0x0B, 0x0C ,0x06, 0x09, 0x00, 0x03, 0x04, 0xA0, 0x00, 0x00, 0x00, 0xAF};

//14443A Select tag
static const UInt8 test_14443a_select_tag_msg[] =       {0x0B, 0x14 ,0x06, 0x11, 0x00, 0x03, 0x04, 0xA2, 0x04, 0x40, 0x72, 0xBE, 0xDA, 0x98, 0x26, 0x80, 0xE4, 0x00, 0x00, 0x25};

//read first 4 blocks
static const UInt8 test_read_first_4_blocks_msg[] =     {0x0B, 0x0D ,0x06, 0x0A, 0x00, 0x03, 0x04, 0x72, 0x30, 0x00, 0x00, 0x00, 0x4F};


//Flomio Accessory-Client Message Opcodes
typedef enum
{
    FLOMIO_STATUS_OP = 1,
    FLOMIO_PROTO_ENABLE_OP,
    FLOMIO_POLLING_ENABLE_OP,
    FLOMIO_POLLING_RATE_OP,
    FLOMIO_TAG_UID_OP,
    FLOMIO_ACK_ENABLE_OP,
    FLOMIO_STANDALONE_OP,
    FLOMIO_STANDALONE_TIMEOUT_OP,
    FLOMIO_DUMP_LOG_OP,
    FLOMIO_LED_CONTROL_OP,
    FLOMIO_TI_HOST_COMMAND_OP,
    FLOMIO_COMMUNICATION_CONFIG_OP,
    FLOMIO_PING_OP
} flomio_opcode_t;

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
    FLOMIO_PORTO_FELICA
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




@interface FJNFCMessage : NSObject

@end
