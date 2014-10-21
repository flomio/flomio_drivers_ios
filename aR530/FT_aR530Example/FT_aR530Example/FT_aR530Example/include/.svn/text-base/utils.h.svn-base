#ifndef __UTILS_H
#define __UTILS_H

#ifdef __cplusplus
extern "C" {
#endif
	
    /*
     // C prototype : void StrToHex(unsigned char *pbDest, char *szSrc, int nLen)
     // parameter(s): [OUT] pbDest - 输出缓冲区
     //				 [IN] szSrc - 字符串
     //				 [IN] dwLen - 16进制数的字节数(字符串的长度/2)
     // return value:
     // remarks     : 将字符串转化为16进制数
     */
    void StrToHex(unsigned char *pbDest, char *szSrc, unsigned int dwLen);
	
	
    /*
     // C prototype : void HexToStr(unsigned char *szDest, unsigned char *pbSrc, int nLen)
     // parameter(s): [OUT] szDest - 存放目标字符串
     //				 [IN] pbSrc - 输入16进制数的起始地址
     //				 [IN] dwLen - 16进制数的字节数
     // return value:
     // remarks     : 将16进制数转化为字符串
     */
    void HexToStr(char *szDest, unsigned char *pbSrc, unsigned int dwLen);
    
    /*
     // C prototype : void InvertBuffer(unsigned char* pbBuffer, unsigned int dwBufferLen);
     // parameter(s): [IN] pbBuffer 数据缓冲区
     //				 [IN] dwBufferLen 数据长度
     // return value:
     // remarks     : 将缓冲区内部的数据高低字节顺序反转.
     */
    void InvertBuffer(unsigned char* pBuffer, unsigned int dwBufferLen);
	
#ifdef __cplusplus
}
#endif

#endif // __UTILS_H


