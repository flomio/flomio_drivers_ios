//
//  FTType.h
//  FTCRa520
//
//  Created by Li Yuelei on 6/25/13.
//  Copyright (c) 2013 FT. All rights reserved.
//

#ifndef FTCRa520_FTType_h
#define FTCRa520_FTType_h

#define FT_FUNCTION_NUM_HANDSHAKE   0x01
#define FT_FUNCTION_NUM_LOADKEY     0x02
#define FT_FUNCTION_NUM_SWIPECARD   0x03

#define FT_FUNCTION_NUM_OPEN_CARD       0x04
#define FT_FUNCTION_NUM_CLOSE_CARD      0x05
#define FT_FUNCTION_NUM_RECOGNIZE       0x06
#define FT_FUNCTION_NUM_TRANSMIT        0x07
#define FT_FUNCTION_NUM_AUTHENTICATE    0x08
#define FT_FUNCTION_NUM_READ_BINARY     0x09
#define FT_FUNCTION_NUM_UPDATE_BINARY   0x0A
#define FT_FUNCTION_NUM_INIT_BLOCK      0x0B
#define FT_FUNCTION_NUM_STORE_BLOCK     0x0C
#define FT_FUNCTION_NUM_INCREMENT       0x0D
#define FT_FUNCTION_NUM_DECREMENT       0x0E
#define FT_FUNCTION_NUM_READ_VALUE      0x0F


#define FT_FUNCTION_NUM_GET_DEVICEID        0x10
#define FT_FUNCTION_NUM_GET_FIRMWAREVERSION 0x11
#define FT_FUNCTION_NUM_GET_DEVICEUID       0x12

#define FT_FUNCTION_NUM_PLAY_SOUND          0x13
#define FT_FUNCTION_NUM_DISABBLE_CONNECT_SOUND 0x14

#define CARD_TYPE_A             0x000A
#define CARD_TYPE_B             0x000B
#define CARD_TYPE_C             0x000C
#define CARD_TYPE_D             0x000D


#define CARD_INNOVISION_TOPAZ  0x10
#define CARD_NXP_MIFARE_UL     0x20
#define CARD_NXP_MIFARE_UL_C   0x21
#define CARD_NXP_MIFARE_1K     0x22
#define CARD_NXP_MIFARE_4K     0x18
#define CARD_NXP_DESFIRE_EV1   0x40
#define CARD_NXP_FELICA        0x50
#define CARD_NXP_TYPE_B        0x60
#define CARD_NXP_M_1_B         0x61
#define CARD_NXP_TOPAZ         0x70

#define NFC_FORUM_MAGIC_NUMBER   0xE1
#define NFC_FORUM_VERSION_NUMBER 0x10

#define NFC_CARD_ES_SUCCESS                     0x00000000
#define NFC_CARD_ES_GENERAL_ERROR               0x00000001
#define NFC_CARD_ES_ARGUMENTS_BAD               0x00000002
#define NFC_CARD_ES_INVALID_CARD_HANDLE         0x00000003
#define NFC_CARD_ES_RESPONSE_TOO_SHORT          0x00000004
#define NFC_CARD_ES_TIMEOUT                     0x00000005
#define NFC_CARD_ES_MEMORY_INSUFFICIENT         0x00000006
#define NFC_CARD_ES_BUFFER_TOO_SMALL            0x00000007
#define NFC_CARD_ES_WAIT                        0x00000008
#define NFC_CARD_ES_KEY_LOCKED                  0x00000009
#define NFC_CARD_ES_DEVICE_BUSY                 0x0000000A
#define NFC_CARD_ES_NO_SMARTCARD                0x0000000B
#define NFC_CARD_ES_FUNCTION_NOT_IMPLEMENTED    0x0000000C
#define NFC_CARD_ES_CC_FILE_IS_EMPTY            0x0000000D
#define NFC_CARD_ES_INVALID_LEN_IN_CC_FILE      0x0000000F
#define NFC_CARD_ES_INVALID_TLV_IN_CC_FILE      0x00000010
#define NFC_CARD_ES_NDEF_IS_NOT_READABLE        0x00000011
#define NFC_CARD_ES_FAILED_SELECT_NDEF_FILE     0x00000012
#define NFC_CARD_ES_FAILED_READ_NDEF_FILE       0x00000013
#define NFC_CARD_ES_ACCEPTABLE_ERROR            0x00000014

#ifndef SCARD_CONTEXT_T
#define SCARD_CONTEXT_T void *
#endif

#include <objc/objc.h>

typedef SCARD_CONTEXT_T SCARDCONTEXT;

typedef unsigned char BYTE;
typedef unsigned int DWORD;
typedef unsigned int WORD;

#ifndef	_SIZE_T
#define	_SIZE_T
typedef	unsigned int size_t;
#endif

#ifndef TRUE
#define TRUE 1
#endif

#ifndef FALSE
#define FALSE 0
#endif

struct _nfc_card_st
{
    char *reader;
    int type_card;
    
    BYTE type;
    BYTE SAK;
    BYTE uidLen;
    BYTE uid[128];
    
    //Felica
    BYTE IDm[8];
    BYTE PMm[8];
    
    
    //type B
    BYTE ATQB;
    
    //type Topaz
    BYTE ATQA[2];
    
    BYTE PUPILen;
    BYTE PUPI[32];
    
    unsigned long protocol;
    unsigned char atr[32];
    size_t atrlen;
    
    size_t capacity;
    
    unsigned short file_id;
    unsigned short max_le;
    unsigned short max_lc;
    
    BOOL prepared;
	BOOL writable;
	BOOL empty;
};
typedef struct _nfc_card_st *nfc_card_t;

#define    A_CARD       0x01
#define    B_CARD       0x02
#define    Felica_CARD  0x04
#define    Topaz_CARD   0x08

#endif
