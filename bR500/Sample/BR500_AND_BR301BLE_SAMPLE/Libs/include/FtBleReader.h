/**
 * @file
 * @This isfeitian's private cmd.
 */


/**
 * Copyright(C) Feitian Technologies Co., Ltd. All rights reserved.
 * FileName:        FtBleReader.h
 * FileIdentify:    FtBleReader.h
 * Description:     FT private method
 * Version:         3.4.9
 * Created by:      shanshan
 * FinishDate:      2016-04-18
 * Revision1:
 **/

#ifndef __FtBleReader_h__
#define __FtBleReader_h__


#include "wintypes.h"

#ifdef __cplusplus
extern "C"
{
#endif
    LONG SCARD_CTL_CODE(unsigned int code);
    /*
    Function: FtGetSerialNum
 
    Parameters:
    hContext 		IN 		Connection context to the PC/SC Resource Manager
    length			IN		length of buffer(>=8)
    buffer       	OUT		Device HID
 
    Description:
    This function userd to get serial number of iR301.
    */
    LONG FtGetSerialNum(SCARDCONTEXT hContext, unsigned int * length,char * buffer);
    
    
    /*
     Function: FtGenerateDeviceUID
     
     Parameters:
     hContext 			IN 		Connection context to the PC/SC Resource Manager
     seedLength			IN		length of Seed Number(>=1 <=48)
     seedBuffer       	OUT		Seed Number
     
     Description:
     This function used to Generate Device UID
     */
    LONG FtGenerateDeviceUID(SCARDCONTEXT hContext,unsigned int seedLength ,unsigned char *seedBuffer);
    
    
    /*
     Function: FtGetDeviceUID
     
     Parameters:
     hContext 			IN 		Connection context to the PC/SC Resource Manager
     uidLength			IN		length of buffer(>=8)
     uidBuffer       	OUT		 Device UID
     
     Description:
     This function used to get  UID of bR500.
     */
    LONG FtGetDeviceUID(SCARDCONTEXT hContext,unsigned int *uidLength, char *uidBuffer);
    
    
    /*
     Function: FtEraseDeviceUID
     
     Parameters:
     hContext 			IN 		Connection context to the PC/SC Resource Manager
     seedLength			IN		length of Seed Number(>=1 <=48)
     seedBuffer       	OUT		Seed Number
     
     Description:
     This function used to Escape Device UID
     */
    LONG FtEraseDeviceUID(SCARDCONTEXT hContext,unsigned int seedLength ,unsigned char *seedBuffer);
    
    
    /*
     Function: FtWriteFlash   
  
     Parameters:
     hContext       IN 		Connection context to the PC/SC Resource Manager
     bOffset		IN		Offset of flash to write
     blength		IN		The length of data
     buffer       	IN		The data for write
  
     Description:
     This function userd to write data to flash.
     */
    LONG FtWriteFlash(SCARDCONTEXT hContext,unsigned int bOffset, unsigned int blength,unsigned char *buffer);
    
    /*
     Function: FtReadFlash
 
     Parameters:
     hContext       IN 		Connection context to the PC/SC Resource Manager
     bOffset		IN		Offset of flash to write
     blength		IN/OUT		The length of read data(in/out)
     buffer       	OUT		The read data
 
     Description:
     This function used to read data from flash.
     */
    LONG FtReadFlash(SCARDCONTEXT hContext,unsigned int bOffset, unsigned int *blength,unsigned char *buffer);
    
    /*
     Function: FtSetTimeout
 
     Parameters:
        hContext	IN	 Connection context to the PC/SC Resource Manager
        dwTimeout 	IN	 New transmission timeout value of between 301 and card (millisecond )
     
     Description:
     The function New transmission timeout value of between 301 and card.
 
     */
    LONG FtSetTimeout(SCARDCONTEXT hContext, DWORD dwTimeout);
    
  
    /*
     Function: FtGetDevVer
     
     Parameters:
     hContext	IN	 Connection context to the PC/SC Resource Manager
     firmwareRevision 	OUT	 firmware Version
     hardwareRevision   OUT     hardwareVersion
     Description:
     The function read the firmware and hardware Version.
     
     */
    
    LONG FtGetDevVer( SCARDCONTEXT hContext,char *firmwareRevision,char *hardwareRevision);
    /*
     Function: FtGetLibVersion
     
     Parameters:
     buffer :buffer of libVersion
     
     
     Description:
     Get the Current Lib Version
     
     */
    void FtGetLibVersion (char *buffer);
    
    
#ifdef __cplusplus
}
#endif

#endif

