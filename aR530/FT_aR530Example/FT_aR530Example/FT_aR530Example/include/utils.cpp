#ifdef WIN32
#include <windows.h>
#endif
#include <ctype.h>

#include "utils.h"


/*
 // C prototype : void StrToHex(unsigned char *pbDest, char *szSrc, unsigned int dwLen)
 // parameter(s): [OUT] pbDest - 输出缓冲区
 //				 [IN] szSrc - 字符串
 //				 [IN] dwLen - 16进制数的字节数(字符串的长度/2)
 // return value:
 // remarks     : 将字符串转化为16进制数
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
 // parameter(s): [OUT] szDest - 存放目标字符串
 //				 [IN] pbSrc - 输入16进制数的起始地址
 //				 [IN] dwLen - 16进制数的字节数
 // return value:
 // remarks     : 将16进制数转化为字符串
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
 // parameter(s): [IN] pbBuffer 数据缓冲区
 //				 [IN] dwBufferLen 数据长度
 // return value:
 // remarks     : 将缓冲区内部的数据高低字节顺序反转.
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

