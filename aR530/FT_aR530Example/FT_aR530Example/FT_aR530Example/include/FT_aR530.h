//
//  FT_aR530.h
//  FT_aR530
//
//  Created by Li Yuelei on 4/17/13.
//  Copyright (c) 2013 FT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FTType.h"

//---------------------------FTaR530Delegate Methods-------------------------------
@protocol FTaR530Delegate <NSObject>

@optional

/*@Name:        -(void)FTNFCDidComplete:(nfc_card_t)cardHandle retData:(unsigned char *)retData retDataLen:(unsigned int)retDataLen functionNum:(unsigned int)funcNum errCode:(unsigned int)errCode;
 *@Function:    This function will be callback when NFC function completed.
 *@Parameter:   OUT:(1).(nfc_card_t)cardHandle:     the card's handle
 *                  (2).(unsigned char *)retData:   return data
 *                  (3).(unsigned int)retDataLen:   return data length
 *                  (4).(unsigned int)funcNum:      The function number
 *                  (5).unsigned int)errCode:       The error code(0-success, other value-error code)
 */
-(void)FTNFCDidComplete:(nfc_card_t)cardHandle retData:(unsigned char *)retData retDataLen:(unsigned int)retDataLen functionNum:(unsigned int)funcNum errCode:(unsigned int)errCode;


/*@Name:        -(void)FTaR530GetInfoDIdComplete:(unsigned char *)retData retDataLen:(unsigned int)retDataLen  functionNum:(unsigned int)functionNum errCode:(unsigned int)errCode;
 *@Function:    This function will be callback when Get Firmware Version or Get Device ID function completed.
 *@Parameter:   OUT:(1).(unsigned char *)retData:   return Data
 *                  (2).(unsigned int)retDataLen:   return Data length
 *                  (3).(unsigned int)functionNum:  The function number
 *                  (4).(unsigned int)errCode:      The error code(0-sucess,other value-error code)
 *
 */
-(void)FTaR530GetInfoDidComplete:(unsigned char *)retData retDataLen:(unsigned int)retDataLen  functionNum:(unsigned int)functionNum errCode:(unsigned int)errCode;
@end
//-------------------------FTaR530Delegate Methods end-----------------------------


@interface FTaR530 : NSObject

+ (NSString *)FTaR530_LibVersion;

//-----------------------------newly added methods---------------------------------
/*@Name:        +(void)aR520_GetDeviceID:(id<FTaR530Delegate>)delegate;
 *@Function:    Get device ID
 *@Parameter:   IN:(id<FTaR530Delegate>)delegate:
 */
+(void)FTaR530_GetDeviceID:(id<FTaR530Delegate>)delegate;

/*@Name:        +(void)aR520_GetFirmwareVersion:(id<FTaR530Delegate>)delegate;
 *@Function:    Get firmware version
 *@Parameter:   IN:(id<FTaR530Delegate>)delegate:
 */
+(void)FTaR530_GetFirmwareVersion:(id<FTaR530Delegate>)delegate;

//---------------------------newly added methods end-------------------------------

//----------------------------aR530 CardReader Methods------------------------------

/*@Name:        +(void)NFC_Card_Open:(id<FTaR530Delegate>)delegate
 *@Funciton:    Open the CardReader and Connect to SmartCard
 *@Parameter:   IN:(id<FTaR530Delegate>)delegate
 */
+(void)NFC_Card_Open:(id<FTaR530Delegate>)delegate withTimeout:(NSInteger)millisecond withRetryCount:(NSInteger) count;

+(void)NFC_Card_OpenStop;

/*@Name:        +(void)NFC_Card_Close:(nfc_card_t)card delegate:(id<FTaR530Delegate>)delegate;
 *@Function:    Close the CardReader and Disconnect with SmartCard
 *@Parameter:   IN: (1).(nfc_card_t)card: SmartCard's handle has been Opened
 *                  (2).(id<FTaR530Delegate>)delegate
 */
+(void)NFC_Card_Close:(nfc_card_t)card delegate:(id<FTaR530Delegate>)delegate;


/*@Name:        +(void)NFC_Card_Recognize:(nfc_card_t)card delegate:(id<FTaR530Delegate>)delegate;
 *@Function:    Recognize the smartcard's type
 *@Parameter:   IN: (1).nfc_card_t card: the pointer SmartCard Handle
 *                  (2).(id<FTaR530Delegate>)delegate
 */
+(void)NFC_Card_Recognize:(nfc_card_t)card delegate:(id<FTaR530Delegate>)delegate;


/*@Name:        +(void)NFC_CArd_Transmit:(nfc_card_t)card sendBuf:(unsigned char *)sendBuf sendLen:(unsigned int)sendLen delegate:(id<FTaR530Delegate>)delegate;
 *@Function:    Transmit APDU to Smart Card
 *@Parameter:   IN: (1).nfc_card_t card: The pointer of smart card handle
 *                  (2).(unsigned char *)sendBuf: Send buffer
 *                  (3).(unsigned int)sendLen: Send buffer length
 *                  (4).(id<FTaR530Delegate>)delegate
 */

+(void)NFC_Card_Transmit:(nfc_card_t)card sendBuf:(unsigned char *)sendBuf sendLen:(unsigned int)sendLen delegate:(id<FTaR530Delegate>)delegate;

//--------------------------aR530 CardReader Methods end----------------------------


//---------------------------Mifare Classic 1k Methods------------------------------

/*@Name:        +(void) Mifare_GeneralAuthenticate:(nfc_card_t)card blockNum:(unsigned char)blockNum keyType:(unsigned char)keyType key:(unsigned char *)key delegate:(id<FTaR530Delegate>)delegate;
 *@Funciton:    Authentication the key of Block
 *@Parameter:   IN: (1).nfc_card_t card: the pointer of smartcard handle
 *                  (2).(unsigned char)blockNum: block number
 *                  (3).(unsigned char)keyType: key tyep(A or B)
 *                  (4).(unsigned char *)key: Authentication key
 *                  (5).(id<FTaR530Delegate>)delegate
 */
+(void) Mifare_GeneralAuthenticate:(nfc_card_t)card blockNum:(unsigned char)blockNum keyType:(unsigned char)keyType key:(unsigned char *)key delegate:(id<FTaR530Delegate>)delegate;


/*@Name:       +(void)Mifare_ReadBinary:(nfc_card_t)card blockNum:(unsigned char)blockNum size:(unsigned char)size delegate:(id<FTaR530Delegate>)delegate;
 *@Function:    Read the binary data of block
 *@Parameter:   IN: (1).nfc_card_t card: The Pointer of smart card handle
 *                  (2).(unsigned char)blockNum: The block number
 *                  (3).size:(unsigned char)size: the data length to read
 *                  (4).(id<FTaR530Delegate>)delegate
 */
+(void)Mifare_ReadBinary:(nfc_card_t)card blockNum:(unsigned char)blockNum size:(unsigned char)size delegate:(id<FTaR530Delegate>)delegate;


/*@Name:        +(void)mifare_UpdateBinary:(nfc_card_t)card blockNum:(unsigned char)blockNum data:(unsigned char *)data size:(unsigned char)size delegate:(id<FTaR530Delegate>)delegate;
 *@Function:    Update the binary data of block
 *@Parameter:   IN: (1).nfc_card_t card: The pointer of smart card handle
 *                  (2).(unsigned char)blockNum: The block number
 *                  (3).(unsigned char *)data: data buffer
 *                  (4).(unsigned char)size: data buffer length
 *                  (5).(id<FTaR530Delegate>)delegate
 */
+(void)mifare_UpdateBinary:(nfc_card_t)card blockNum:(unsigned char)blockNum data:(unsigned char *)data size:(unsigned char)size delegate:(id<FTaR530Delegate>)delegate;


/*@Name:        +(void)Mifare_ClassicBlockInitial:(nfc_card_t)card blockNum:(unsigned char)blockNum delegate:(id<FTaR530Delegate>)delegate;
 *@Function:    Initialize the value of block
 *@Parameter:   IN: (1).nfc_card_t card: The pointer of smart card handle
 *                  (2).(unsigned char)blockNum: The block number
 *                  (3).(id<FTaR530Delegate>)delegate
 */
+(void)Mifare_ClassicBlockInitial:(nfc_card_t)card blockNum:(unsigned char)blockNum delegate:(id<FTaR530Delegate>)delegate;


/*@Name:        +(void)Mifare_ClassicStoreBlock:(nfc_card_t)card blockNum:(unsigned char)blockNum valueAmount:(unsigned int)valueAmount delegate:(id<FTaR530Delegate>)delegate;
 *@Function:    Store value to the block
 *@Parameter:   IN: (1).nfc_card_t card: The pointer of smart card handle
 *                  (2).(unsigned char)blockNum:  The block number
 *                  (3).(unsigned int)valueAmount:  The value to store
 *                  (4).(id<FTaR530Delegate>)delegate
 */
+(void)Mifare_ClassicStoreBlock:(nfc_card_t)card blockNum:(unsigned char)blockNum valueAmount:(unsigned int)valueAmount delegate:(id<FTaR530Delegate>)delegate;


/*@Name:        +(void)Mifare_ClassicIncrement:(nfc_card_t)card blockNum:(unsigned char)blockNum valueAmount:(unsigned int)valueAmount delegate:(id<FTaR530Delegate>)delegate;
 *@Function:    Increment the value of block
 *@Parameter:   IN: (1).nfc_card_t card: The pointer of smart card handle
 *                  (2).(unsigned char)blockNum: The block number
 *                  (3).(unsigned int)valueAmount: The value to Increment
 *                  (4).(id<FTaR530Delegate>)delegate
 */
+(void)Mifare_ClassicIncrement:(nfc_card_t)card blockNum:(unsigned char)blockNum valueAmount:(unsigned int)valueAmount delegate:(id<FTaR530Delegate>)delegate;


/*@Name:        +(void)Mifare_ClassicDecrement:(nfc_card_t)card blockNum:(unsigned char)blockNum valueAmount:(unsigned int)valueAmount delegate:(id<FTaR530Delegate>)delegate;
 *@Function:    Decrement the value of block
 *@Parameter:   IN: (1).nfc_card_t card: The pointer of smart card handle
 *                  (2).(unsigned char)blockNum: The block number
 *                  (3).(unsigned int)valueAmount: The value to Decrement
 *                  (4).(id<FTaR530Delegate>)delegate
 */
+(void)Mifare_ClassicDecrement:(nfc_card_t)card blockNum:(unsigned char)blockNum valueAmount:(unsigned int)valueAmount delegate:(id<FTaR530Delegate>)delegate;


/*@Name:        +(void)Mifare_ClassicReadValue:(nfc_card_t)card blockNum:(unsigned char)blockNum delegate:(id<FTaR530Delegate>)delegate;
 *@Function:    Read the value of block
 *@Parameter:   IN: (1).nfc_card_t card: The pointer of smart card handle
 *                  (2).(unsigned char)blockNum:  The block number to read
 *                  (3).(id<FTaR530Delegate>)delegate
 */
+(void)Mifare_ClassicReadValue:(nfc_card_t)card blockNum:(unsigned char)blockNum delegate:(id<FTaR530Delegate>)delegate;

//--------------------------Mifare Classic 1k Methods end----------------------------
+(void)removeDelegate;
@end


//--------------------------aR520 CardRead Listener Methods---------------------------

/*@Name:        typedef void(NOTIFY_RECEIVER)(unsigned char is_inserted,void* user_data);
 *@Function:    define a audio device listening function
 */
typedef void(NOTIFY_RECEIVER)(unsigned char is_inserted,void* user_data);

/*@Name:        FTRegistMonitor(NOTIFY_RECEIVER* receiver, void* user_data);
 *@Function:    regist a listening fuction to handle audio device event
 *@Parameter:   IN: (1).NOTIFY_RECEIVER* receiver: event handle function
 *                  (2).void* user_data: user's data
 */
void FTRegistMonitor(NOTIFY_RECEIVER* receiver, void* user_data);

/*@Name:        FTUnregistMonitor(NOTIFY_RECEIVER* receiver, void * user_data);
 *@Function:    unregist a listening function
 *@Parameter:   IN: (1).NOTIFY_RECEIVER* receiver: the listening function
 *                  (2).void * user_data: user's data
 */
void FTUnregistMonitor(NOTIFY_RECEIVER* receiver, void * user_data);

//------------------------aR520 CardRead Listener Methods end-------------------------

extern BYTE g_cardType;
extern bool stopRetry;

