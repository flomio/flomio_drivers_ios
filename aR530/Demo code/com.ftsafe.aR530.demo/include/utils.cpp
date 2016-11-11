#ifdef WIN32
#include <windows.h>
#endif
#include <ctype.h>

#include "utils.h"


/*
 // C prototype : void StrToHex(unsigned char *pbDest, char *szSrc, unsigned int dwLen)
 // parameter(s): [OUT] pbDest - Output Buffer
 //				 [IN] szSrc - String
 //				 [IN] dwLen - The number of bytes hexadecimal number ( string length / 2 )
 // return value:
 // remarks     : Convert string to HEX
 */
void StrToHex(unsigned char *pbDest, char *szSrc, unsigned int dwLen)
{
	char h1,h2;
	unsigned char s1,s2;
	
	for (int i=0; i<dwLen; i++)
	{
		h1 = szSrc[2*i];
		h2 = szSrc[2*i+1];
		
		s1 = toupper(h1) - 0x30;
		if (s1 > 9)
			s1 -= 7;
		
		s2 = toupper(h2) - 0x30;
		if (s2 > 9)
			s2 -= 7;
		
		pbDest[i] = s1*16 + s2;
    }
}

/*
 // C prototype : void HexToStr(char *szDest, unsigned char *pbSrc, unsigned int dwLen)
 // parameter(s): [OUT] szDest - Output Buffer
 //				 [IN] pbSrc - Enter the starting address hexadecimal numbers
 //				 [IN] dwLen - buffer length
 // return value:
 // remarks     : The hexadecimal number is converted to a string
 */
void HexToStr(char *szDest, unsigned char *pbSrc, unsigned int dwLen)
{
	char	ddl,ddh;
	
	for (int i=0; i<dwLen; i++)
	{
		ddh = 48 + pbSrc[i] / 16;
		ddl = 48 + pbSrc[i] % 16;
		if (ddh > 57)  ddh = ddh + 7;
		if (ddl > 57)  ddl = ddl + 7;
		szDest[i*2] = ddh;
		szDest[i*2+1] = ddl;
	}
	
	szDest[dwLen*2] = '\0';
}

/*
 // C prototype : void InvertBuffer(unsigned char* pbBuffer, unsigned int dwBufferLen);
 // parameter(s): [IN] pbBuffer Input Buffer
 //				 [IN] dwBufferLen buffer size
 // return value:
 // remarks     : To reversal buffer data within the height of bytes
 */
void InvertBuffer(unsigned char* pBuffer, unsigned int dwBufferLen)
{
	unsigned char tmp = 0;
	
	for(unsigned long i = 0; i < dwBufferLen / 2; ++i)
	{
		tmp = pBuffer[i];
		pBuffer[i] = pBuffer[dwBufferLen - i - 1];
		pBuffer[dwBufferLen - i - 1] = tmp;
	}	
}

