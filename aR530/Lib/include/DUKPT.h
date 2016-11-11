//
//  DUKPT.h
//  ApayPass_DUKPT_lib
//
//  Created by Li Yuelei on 1/16/13.
//  Copyright (c) 2013 FT. All rights reserved.
//

#ifndef ApayPass_DUKPT_lib_DUKPT_h
#define ApayPass_DUKPT_lib_DUKPT_h

#ifdef __cplusplus
extern "C" {
    
#endif

/****************************************************************************
 *   function   :calculate the ipek
 *   input      :unsigned char *bdk (user's bdk);
                 unsigned char *ksn (user's ksn).
 *   output     :unsigned char *ipek
 *****************************************************************************/
//ANSIX9.24PART1-2004 page45?
void derive_IPEK(unsigned char *bdk, unsigned char *ksn, unsigned char *ipek);

/****************************************************************************
 *   Function   :calculate the key
 *   input      :unsigned char *ipek(the ipek calculate from derive_IPEK());
                 unsigned char *ksn (user's ksn).
 *   output     :unsigned char *pek (the key of DES)
 *****************************************************************************/
//ANSIX9.24PART1-2004 page54ok
void derive_PEK(unsigned char *ipek, unsigned char *ksn, unsigned char *pek);


/****************************************************************************
 *   function   :DUKPT Decipher
 *   input      :unsigned char *ipek(the key calculate from derive_PEK());
                 unsigned char *ksn(The ksn return from device);
                 unsigned char *cryptogram(ciphertext);
                 unsigned int *cryptlen(ciphertext length).
 *   output     : unsigned char *out(plaintext).
 *****************************************************************************/
void DECRYPT(unsigned char *ipek, unsigned char *ksn, unsigned char *cryptogram, unsigned char *out, unsigned int *cryptlen);
    
#ifdef __cplusplus
}
#endif

#endif
