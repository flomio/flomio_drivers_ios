#ifndef __UTILS_H
#define __UTILS_H

#ifdef __cplusplus
extern "C" {
#endif
	
    /*
	 // C prototype : void StrToHex(unsigned char *pbDest, char *szSrc, unsigned int dwLen)
	 // parameter(s): [OUT] pbDest - Output Buffer
	 //				 [IN] szSrc - String
	 //				 [IN] dwLen - The number of bytes hexadecimal number ( string length / 2 )
	 // return value:
	 // remarks     : Convert string to HEX
     */
    void StrToHex(unsigned char *pbDest, char *szSrc, unsigned int dwLen);
	
	
    /*
	 // C prototype : void HexToStr(char *szDest, unsigned char *pbSrc, unsigned int dwLen)
	 // parameter(s): [OUT] szDest - Output Buffer
	 //				 [IN] pbSrc - Enter the starting address hexadecimal numbers
	 //				 [IN] dwLen - buffer length
	 // return value:
	 // remarks     : The hexadecimal number is converted to a string
     */
    void HexToStr(char *szDest, unsigned char *pbSrc, unsigned int dwLen);
    
    /*
	 // C prototype : void InvertBuffer(unsigned char* pbBuffer, unsigned int dwBufferLen);
	 // parameter(s): [IN] pbBuffer Input Buffer
	 //				 [IN] dwBufferLen buffer size
	 // return value:
	 // remarks     : To reversal buffer data within the height of bytes
     */
    void InvertBuffer(unsigned char* pBuffer, unsigned int dwBufferLen);
	
#ifdef __cplusplus
}
#endif

#endif // __UTILS_H


