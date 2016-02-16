

#ifndef __winscard_h__
#define __winscard_h__


#include "wintypes.h"

#ifdef __cplusplus
extern "C"
{
#endif

#ifndef PCSC_API
#define PCSC_API
#endif
    
#define MAX_ATR_SIZE			33
	
    typedef LONG SCARDCONTEXT; /**< \p hContext returned by SCardEstablishContext() */
    typedef SCARDCONTEXT *PSCARDCONTEXT;
    typedef SCARDCONTEXT *LPSCARDCONTEXT;
    typedef LONG SCARDHANDLE; /**< \p hCard returned by SCardConnect() */
    typedef SCARDHANDLE *PSCARDHANDLE;
    typedef SCARDHANDLE *LPSCARDHANDLE;
    
    
    typedef struct
    {
        const char *szReader;
        const char *pvUserData;
        DWORD dwCurrentState;
        DWORD dwEventState;
        DWORD cbAtr;
        DWORD isConnected;
        unsigned char rgbAtr[MAX_ATR_SIZE];
    }
    SCARD_READERSTATE, *LPSCARD_READERSTATE;
	/** Protocol Control Information (PCI) */
	typedef struct _SCARD_IO_REQUEST
	{
		uint32_t dwProtocol;	/**< Protocol identifier */
		uint32_t cbPciLength;	/**< Protocol Control Inf Length */
	}
	SCARD_IO_REQUEST, *PSCARD_IO_REQUEST, *LPSCARD_IO_REQUEST;
	
	typedef const SCARD_IO_REQUEST *LPCSCARD_IO_REQUEST;
	
	extern SCARD_IO_REQUEST g_rgSCardT0Pci, g_rgSCardT1Pci,
	g_rgSCardRawPci;

	PCSC_API LONG SCardEstablishContext(DWORD dwScope,
		/*@null@*/ LPCVOID pvReserved1, /*@null@*/ LPCVOID pvReserved2,
		/*@out@*/ LPSCARDCONTEXT phContext);

	PCSC_API LONG SCardReleaseContext(SCARDCONTEXT hContext);

	PCSC_API LONG SCardIsValidContext(SCARDCONTEXT hContext);

	PCSC_API LONG SCardConnect(SCARDCONTEXT hContext,
		LPCSTR szReader,
		DWORD dwShareMode,
		DWORD dwPreferredProtocols,
		/*@out@*/ LPSCARDHANDLE phCard, /*@out@*/ LPDWORD pdwActiveProtocol);

	PCSC_API LONG SCardDisconnect(SCARDHANDLE hCard, DWORD dwDisposition);

	PCSC_API LONG SCardBeginTransaction(SCARDHANDLE hCard);

	PCSC_API LONG SCardEndTransaction(SCARDHANDLE hCard, DWORD dwDisposition);

	PCSC_API LONG SCardStatus(SCARDHANDLE hCard,
		/*@null@*/ /*@out@*/ LPSTR mszReaderName,
		/*@null@*/ /*@out@*/ LPDWORD pcchReaderLen,
		/*@null@*/ /*@out@*/ LPDWORD pdwState,
		/*@null@*/ /*@out@*/ LPDWORD pdwProtocol,
		/*@null@*/ /*@out@*/ LPBYTE pbAtr,
		/*@null@*/ /*@out@*/ LPDWORD pcbAtrLen);

	PCSC_API LONG SCardGetStatusChange(SCARDCONTEXT hContext,
		DWORD dwTimeout,
		LPSCARD_READERSTATE rgReaderStates, DWORD cReaders);

	PCSC_API LONG SCardControl(SCARDHANDLE hCard, DWORD dwControlCode,
		LPCVOID pbSendBuffer, DWORD cbSendLength,
		/*@out@*/ LPVOID pbRecvBuffer, DWORD cbRecvLength,
		LPDWORD lpBytesReturned);

	PCSC_API LONG SCardTransmit(SCARDHANDLE hCard,
		const SCARD_IO_REQUEST *pioSendPci,
		LPCBYTE pbSendBuffer, DWORD cbSendLength,
		/*@out@*/ SCARD_IO_REQUEST *pioRecvPci,
		/*@out@*/ LPBYTE pbRecvBuffer, LPDWORD pcbRecvLength);

	PCSC_API LONG SCardListReaderGroups(SCARDCONTEXT hContext,
		/*@out@*/ LPSTR mszGroups, LPDWORD pcchGroups);

	PCSC_API LONG SCardListReaders(SCARDCONTEXT hContext,
		/*@null@*/ /*@out@*/ LPCSTR mszGroups,
		/*@null@*/ /*@out@*/ LPSTR mszReaders,
                                   /*@out@*/ LPDWORD pcchReaders);

	PCSC_API LONG SCardCancel(SCARDCONTEXT hContext);
    PCSC_API LONG SCardReconnect(SCARDHANDLE hCard, DWORD dwShareMode,
                        DWORD dwPreferredProtocols, DWORD dwInitialization,
                                 LPDWORD pdwActiveProtocol);

	PCSC_API LONG SCardGetAttrib(SCARDHANDLE hCard, DWORD dwAttrId,
		/*@out@*/ LPBYTE pbAttr, LPDWORD pcbAttrLen);
    
    
#ifdef __cplusplus
}
#endif

#endif

