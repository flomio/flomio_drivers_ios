/**
 * @file
 * @This isfeitian's private cmd.
 */

#ifndef __ft301u_h__
#define __ft301u_h__


#include "wintypes.h"

#ifdef __cplusplus
extern "C"
{
#endif
    LONG SCARD_CTL_CODE(unsigned int code);
    /*
    Function: FtGetSerialNum
 
    Parameters:
    hCard 			IN 		Connection made from SCardConnect(Ignore this parameter and just set to zero in iOS system)
    length			IN		length of buffer(>=8)
    buffer       	OUT		Serial number
 
    Description:
    This function userd to get serial number of iR301.
    */
    
    LONG FtGetSerialNum(SCARDHANDLE hCard, unsigned int * length,
                                      char * buffer);
    /*
     Function: FtWriteFlash   
  
     Parameters:
     hCard          IN 		Connection made from SCardConnect(Ignore this parameter and just set to zero in iOS system)
     bOffset		IN		Offset of flash to write
     blength		IN		The length of data
     buffer       	IN		The data for write
  
     Description:
     This function userd to write data to flash.
     */
    LONG FtWriteFlash(SCARDHANDLE hCard,unsigned char bOffset, unsigned char blength,
                      unsigned char buffer[]);
    /*
     Function: FtReadFlash
 
     Parameters:
     hCard 			IN 		Connection made from SCardConnect(Ignore this parameter and just set to zero in iOS system)
     bOffset		IN		Offset of flash to write
     blength		IN		The length of read data
     buffer       	OUT		The read data
 
     Description:
     This function used to read data from flash.
     */
    LONG FtReadFlash(SCARDHANDLE hCard,unsigned char bOffset, unsigned char blength,
                     unsigned char buffer[]);
    
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
     The function New transmission timeout value of between 301 and card.
     
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

