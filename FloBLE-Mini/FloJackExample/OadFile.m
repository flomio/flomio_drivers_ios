//
//  OadFile.m
//  FlobleOSX
//
//  Created by Chuck Carter on 2/25/15.
//  Copyright (c) 2015 Flomio. All rights reserved.
//

#import "OadFile.h"
//#import <stdio.h>
#import <stdlib.h>


@implementation OadFile

@synthesize currentFirmwareVersion;
@synthesize imageVersion;
@synthesize oadFileName;
@synthesize oadData;
@synthesize oadHexFile;
@synthesize oadDataLength;
@synthesize currentImageType;
@synthesize oadImageType;
@synthesize oadImageHeader;
@synthesize isUploadInProgress;
@synthesize canceled;
@synthesize uploadComplete;
@synthesize hasValidFile;
@synthesize isConnected;
@synthesize index;
@synthesize pNextIndex;
@synthesize bytesToSend;
@synthesize bytesSent;
@synthesize blocksToSend;
@synthesize blocksSent;

@synthesize delegate;

- (id)init
{
    self = [super init];
    if(self)
    {
        currentFirmwareVersion = @" - ";
        currentImageType = undefinedType;
        imageVersion = @" - ";
        [self resetOadFileAttributes];
        [self resetOadUploadAttributes];
//        hasValidFile = NO;
        isConnected = NO;
    }
    return self;
}

- (id)initWithDelegate:(id<OadFileDelegate>)oadFileDelegate
{
    self = [self init];
    if (self)
    {
        delegate = oadFileDelegate;
    }
    return self;
}


- (void)extractImageHeader
{
    UInt8* uartByte = (UInt8*)oadData.bytes;     //theData.bytes;

    memcpy(&oadImageHeader, &uartByte[0 + OAD_IMG_HDR_OSET], sizeof(oad_img_hdr_t));
    oadImageType = (imageType)(oadImageHeader.ver & 0x01);
    oadDataLength = [oadData length];
    bytesSent = 0;
    blocksSent = 0;
    bytesToSend = oadImageHeader.len * HAL_FLASH_WORD_SIZE;
    blocksToSend = oadImageHeader.len / (OAD_BLOCK_SIZE / HAL_FLASH_WORD_SIZE);

}
//oad_img_metadata_t oadImageMetaData;

//convert from hex file format to bin file format;
- (void)extractImageHeader:(NSData *)hexFile
{
#define SHOULD_BE_COPIED 0xFF
#define ALREADY_COPIED 0x80
#define APPLICATION 0x01
#define APPLICATION_PLUS_STACK 0x02
#define NETWORK_PROCESSOR 0x03
    
#define ON_CHIP_FLASH_START 0x0000
#define ON_CHIP_APP_START   0x1000
#define ON_CHIP_APP_END     0xDFFF //0xBFFF

#define DATA_START_OFFSET 9
#define END_CRC_LEN 2
#define END_NEWLINE_LEN 2
    
    char str[16];

    NSInteger fileLen = hexFile.length; // length of hex file data
    NSRange range;
    UInt16 address;
    UInt8 num;

//    UInt8* uartByte = (UInt8*)hexFile.bytes;     //theData.bytes;
    
//    range.location = 3; range.length = 4; str[4] = 0;
//    [hexFile getBytes:str range:range];
//    address  = (UInt16)strtol(str,NULL,16);
    address = ON_CHIP_APP_START;  // Start of FLASH
    

    char * numbs = (char*)malloc(sizeof(char)*(ON_CHIP_APP_END-ON_CHIP_FLASH_START+1));

    for(int i = 0; i <= (ON_CHIP_APP_END-ON_CHIP_FLASH_START); i++)
    {
        numbs[i] = 0xFF;
    }

    NSInteger fileReadCount = 0;  // num of chars read from hex file
    NSInteger binDataLen = 0;  // binary data length
    NSInteger lineLen;
    NSInteger lineStart = 0;
    bool stop = NO;
    str[2] = 0;
    UInt16 lineAddress = 0;
    int lineOffset = 0;
    UInt16 lastAddress = 0;

    while ((fileReadCount < fileLen) && (!stop))
    {
        // get first line
        range.location = lineStart+3; range.length = 4; str[4] = 0;
        [hexFile getBytes:str range:range];
        lineAddress  = (UInt16)strtol(str,NULL,16);

        range.location = lineStart+1; range.length = 2; str[2] = 0;
        [hexFile getBytes:str range:range];
        lineLen  = (UInt16)strtol(str,NULL,16);
        lineOffset = 0;
        for (int j = 0; j < lineLen*2; j+=2)
        {
            range.location = lineStart + j + DATA_START_OFFSET; range.length = 2 ;
            [hexFile getBytes:str range:range];
            num  = (UInt16)strtol(str,NULL,16);
            numbs[lineAddress+lineOffset] = (char)num;
            lastAddress = lastAddress < lineAddress+lineOffset ? lineAddress+lineOffset :lastAddress;
            lineOffset += 1;
            binDataLen += 1;
        }
        fileReadCount += lineLen+lineLen + DATA_START_OFFSET + END_CRC_LEN+2;
        lineStart += lineLen+lineLen + DATA_START_OFFSET + END_CRC_LEN+2;
    }
    
    // Flush out to modulo 4 in length
//    int rem = 15 - (lastAddress - address)%16;
    int rem = ON_CHIP_APP_END - lastAddress;
    for(int i = 0; i < rem; i++)
    {
        lastAddress += 1;
        numbs[lastAddress] = 0xFF;
        binDataLen += 1;
    }

    // compute CRC
    UInt16 imageCRC = 0;

    for(int i = ON_CHIP_APP_START+4; i <= lastAddress; i++)
    {
        imageCRC = crc16(imageCRC, (UInt8) numbs[i]);
    }
    // IAR note explains that poly must be run with value zero for each byte of
    // the crc.
    imageCRC = crc16(imageCRC, 0);
    imageCRC = crc16(imageCRC, 0);
    

    oadData = [NSData dataWithBytes:numbs length:lastAddress+1];
//    NSString * wrPath = @"/Users/ccarter/pc_shared/FlomioVisaNightlyBackup/hexFile.bin";
//    [oadData writeToFile:wrPath atomically:NO];
    free(numbs);

    oadImageHeader.crc0 = (UInt16) imageCRC;  // crc[0]
    oadImageHeader.crc1 = 0xFFFF;   // shadow CRC
    oadImageHeader.ver = 0x0000 ;   // Ignore version number and always over write
    oadImageHeader.len = (lastAddress+1-address)>> 2; //binDataLen>>2;
    oadImageHeader.uid[0] = 0x45;oadImageHeader.uid[1] = 0x45;oadImageHeader.uid[2] = 0x45;oadImageHeader.uid[3] = 0x45;  // = "E"
    oadImageHeader.res[0] = (UInt8) ((ON_CHIP_APP_START>>2) & 0x00FF);  //0x00;  // Address
    oadImageHeader.res[1] = (UInt8)((ON_CHIP_APP_START>>2) >> 8);  //0x04;  // Address  = 0x1000
//    oadImageHeader.res[0] = (UInt8) ((address>>2) & 0x00FF);  // Address
//    oadImageHeader.res[1] = (UInt8)((address>>2) >> 8);   // Address  = 0x1000
    oadImageHeader.res[2] = APPLICATION; // Type
    oadImageHeader.res[3] = SHOULD_BE_COPIED;  // State
 
    imageVersion = 0x0000;
    oadImageType = (imageType)(oadImageHeader.ver & 0x03);
    oadDataLength = oadImageHeader.len * HAL_FLASH_WORD_SIZE; //[oadData length];
    bytesSent = 0;
    blocksSent = 0;
    bytesToSend = oadImageHeader.len * HAL_FLASH_WORD_SIZE;
    blocksToSend = oadImageHeader.len / (OAD_BLOCK_SIZE / HAL_FLASH_WORD_SIZE);

    address = (oadImageHeader.res[0] | oadImageHeader.res[1] << 8)*4;
    
    NSLog(@"address 0x%4.4x  binDataLen 0x%4.4x crc 0x%4.4x\n ",address, (lastAddress-address + 1), imageCRC);
    NSLog(@"bytesToSend %ld  blocksToSend %ld \n ",(long)bytesToSend, (long)blocksToSend);
  
}


- (void)clearImageHeader
{
    oadImageHeader.crc0 = 0;
    oadImageHeader.crc1 = 0;
    oadImageHeader.ver = 0;
    oadImageHeader.len = 0;
    oadImageHeader.uid[0] = 0;oadImageHeader.uid[1] = 0;oadImageHeader.uid[2] = 0;oadImageHeader.uid[0] = 0;
    oadImageHeader.res[0] = 0;oadImageHeader.res[1] = 0;oadImageHeader.res[2] = 0;oadImageHeader.res[3] = 0;
    oadImageType = undefinedType;
    oadDataLength = 0;
}

- (NSData*)getOadHeaderBlock
{
    UInt8 headerData[OAD_IMG_METADATA_SIZE]; // 16Bytes
    
    headerData[0] = LO_UINT16(oadImageHeader.crc0);
    headerData[1] = HI_UINT16(oadImageHeader.crc0);

    headerData[2] = LO_UINT16(oadImageHeader.crc1);
    headerData[3] = HI_UINT16(oadImageHeader.crc1);

    headerData[4] = LO_UINT16(oadImageHeader.ver);
    headerData[5] = HI_UINT16(oadImageHeader.ver);
    
    headerData[6] = LO_UINT16(oadImageHeader.len);
    headerData[7] = HI_UINT16(oadImageHeader.len);

    memcpy(headerData + 8, &oadImageHeader.uid, sizeof(oadImageHeader.uid));

    memcpy(headerData + 12, &oadImageHeader.res, sizeof(oadImageHeader.res));

    NSData* headerBlock = [NSData dataWithBytes:headerData length:OAD_IMG_METADATA_SIZE];


#if 0
//    NSData* headerBlock = [NSData dataWithBytes:oadData.bytes length:sizeof(oad_img_hdr_t)];
    UInt8 headerData[OAD_IMG_HDR_SIZE + 2 + 2]; // 12Bytes
  
    headerData[0] = LO_UINT16(oadImageHeader.ver);
    headerData[1] = HI_UINT16(oadImageHeader.ver);
    
    headerData[2] = LO_UINT16(oadImageHeader.len);
    headerData[3] = HI_UINT16(oadImageHeader.len);
    
    NSLog(@"Image version = %04hx, len = %04hx",oadImageHeader.ver,oadImageHeader.len);
    
    memcpy(headerData + 4, &oadImageHeader.uid, sizeof(oadImageHeader.uid));
    
    headerData[OAD_IMG_HDR_SIZE + 0] = LO_UINT16(12);
    headerData[OAD_IMG_HDR_SIZE + 1] = HI_UINT16(12);
    
    headerData[OAD_IMG_HDR_SIZE + 2] = LO_UINT16(15);
    headerData[OAD_IMG_HDR_SIZE + 3] = HI_UINT16(15);

    
    
    NSData* headerBlock = [NSData dataWithBytes:headerData length:OAD_IMG_HDR_SIZE + 2 + 2];
    
#endif
    return headerBlock;
}

- (NSData*)getOadDataBlockAtIndex:(NSInteger)theIndex
{
    NSRange blockRange;
    UInt16 appStartAddress = (oadImageHeader.res[0] | oadImageHeader.res[1] << 8)*4;

    blockRange.length = OAD_BLOCK_SIZE;
    blockRange.location = theIndex*(OAD_BLOCK_SIZE)+appStartAddress;
    
    UInt8 oadDataStuff[2+OAD_BLOCK_SIZE];
    oadDataStuff[0] = LO_UINT16(theIndex);
    oadDataStuff[1] = HI_UINT16(theIndex);

    
    [oadData getBytes:&oadDataStuff[2] range:blockRange];
    

    NSData* dataBlock = [NSData dataWithBytes:oadDataStuff length:2+OAD_BLOCK_SIZE];
    return dataBlock;
}

- (bool)validateImageTypes
{
    return YES;  // cc2650 has only one type of image
/*
    if ((currentImageType == undefinedType) || (oadImageType == undefinedType))
    {
        return NO;
    }
    else
    {
        return (currentImageType != oadImageType);
    }
 */
}

- (bool)requestCurrentImageType
{
    /*
    unsigned char data = 0x01;
    NSData* block = [NSData dataWithBytes:&data length:1];
    [delegate writeBlockToOadImageIdentify:(NSData*)block];
     */
    return YES;
}

- (bool)initiateUpload
{
    [self resetOadUploadAttributes];
    canceled = NO;

    if ([self validateImageTypes])
    {
        isUploadInProgress = YES;
        uploadComplete = NO;
        bytesToSend = oadImageHeader.len * HAL_FLASH_WORD_SIZE;
        
        return YES;

    }
    else
    {
        // display error dialog
        NSLog(@"Failed imageTypes %2.2lx %2.2lx",currentImageType, oadImageType);
        return NO;
    }
}

- (bool)establishUpload
{
     NSData* block = [self getOadHeaderBlock];
//    [self.floReaderManager.nfcService writeBlockToOadImageIdentifyWithOutResponse:&block.bytes[0] ofLength:sizeof(oad_img_hdr_t)];
    [delegate writeBlockToOadImageIdentify:block];

    return YES;
}

- (bool)doUpload
{
    if (canceled)
    {
        isUploadInProgress = NO;
        return NO;
    }
    else if(isUploadInProgress && (index < blocksToSend))
    {
        NSInteger p = index;
        for(int i = 0; i < 4; i++)
        {
            NSData* block = [self getOadDataBlockAtIndex:p];
            [delegate writeBlockToOadBlockTransfer:block];
            bytesSent = p*OAD_BLOCK_SIZE;
            blocksSent = p;
            p += 1;
            if(p >= blocksToSend)
            {
                uploadComplete = YES;
                break;
            }
        }
        pNextIndex = p;
        return YES;
    }
    else
    {
        uploadComplete = YES;
        return NO;
    }
}

- (bool)endUpload
{
    [self setCanceled:NO];
    [self setIsUploadInProgress:NO];
    [self resetOadUploadAttributes];
    [self.delegate endOfUploadNotification];
    return YES;
}

- (bool)cancelUpload
{
    [self setCanceled:YES];
    [self resetOadUploadAttributes];
    [self.delegate cancelationOfUploadNotification];
    return YES;
}

- (void)receivedImageBlockTransferCharacteristic:(NSData*)imageBlockCharacteristic
{
    UInt8 * theBytes = (UInt8*)imageBlockCharacteristic.bytes;
    index = theBytes[1] << 8 | theBytes[0];
//    NSLog(@"receivedImageBlockTransferCharacteristic %@ %ld",imageBlockCharacteristic, index);
    if ((index >= pNextIndex) && (isUploadInProgress))
    {
        [self doUpload];
    }
    if (uploadComplete)
    {
        [self endUpload];
    }
}

- (void)receivedImageIdentifyCharacteristic:(NSData*)imageBlockCharacteristic
{
//    unsigned char data[imageBlockCharacteristic.value.length];
//    [characteristic.value getBytes:&data];
//    self.imgVersion = ((UInt16)data[1] << 8 & 0xff00) | ((UInt16)data[0] & 0xff);
//    NSLog(@"self.imgVersion : %04hx",self.imgVersion);

    
    UInt8* bytes = (UInt8*)imageBlockCharacteristic.bytes;
    NSInteger version = ((UInt16)bytes[1] << 8 & 0xff00) | ((UInt16)bytes[0] & 0xff);
    
    [self setCurrentImageType:(imageType)(version & 1)];

    
    NSLog(@"receivedImageIdentifyCharacteristic %@ version %04lx",imageBlockCharacteristic,(long)version);

}
#pragma mark - handcrafted accessors

- (void)setConnectedState:(BOOL)connectedState
{
    if (self.isConnected && !connectedState && isUploadInProgress) // we disconnected during an upload
    {
        self.canceled = YES;
        [self setCurrentImageType:undefinedType];
        // send alert
    }
    else if (self.isConnected && !connectedState) // we disconnected
    {
        [self setCurrentImageType:undefinedType];
    }
    else if (!self.isConnected && connectedState) // we just connected
    {
        [self requestCurrentImageType];
    }

    self.isConnected = connectedState;
    NSLog(@"setConnectedState %d", [self isConnected]);

}

#pragma mark - Utilities

- (void)handleWindowIsClosing
{
    if (self.isUploadInProgress)
    {
        self.canceled = YES;
    }
}

- (void)resetOadFileAttributes
{
//    currentFirmwareVersion = @" - ";
//    currentImageType = undefinedType;
    oadImageType = undefinedType;
    oadImageHeader.crc0 = 0;
    oadImageHeader.crc1 = 0;
    oadImageHeader.ver = 0;
    oadImageHeader.len = 0;
    oadImageHeader.uid[0] = 0;oadImageHeader.uid[1] = 0;oadImageHeader.uid[2] = 0;oadImageHeader.uid[0] = 0;
    oadImageHeader.res[0] = 0;oadImageHeader.res[1] = 0;oadImageHeader.res[2] = 0;oadImageHeader.res[3] = 0;
    oadFileName = [[NSMutableString alloc ]initWithCapacity:128];//@"-.bin";
    [oadFileName setString:@"https://dl.dropboxusercontent.com/u/74911655/SimpleBLEPeripheral_411.hex"];
    oadDataLength = 0;
    hasValidFile = NO;
    blocksToSend = 0;
    bytesToSend = 0;
  
}

- (void)resetOadUploadAttributes
{
    isUploadInProgress = NO;
    canceled = NO;
    uploadComplete = NO;
//    isConnected = NO;
    index = 0;
    pNextIndex = 0;
    bytesSent = 0;
    blocksSent = 0;
}

/*********************************************************************
 * @fn          crc16
 *
 * @brief       Run the CRC16 Polynomial calculation over the byte parameter.
 *
 * @param       crc - Running CRC calculated so far.
 * @param       val - Value on which to run the CRC16.
 *
 * @return      crc - Updated for the run.
 */
static UInt16 crc16(UInt16 crc, UInt8 val)
{
    const UInt16 poly = 0x1021;
    UInt8 cnt;
    
    for (cnt = 0; cnt < 8; cnt++, val <<= 1)
    {
        UInt8 msb = (crc & 0x8000) ? 1 : 0;
        
        crc <<= 1;
        
        if (val & 0x80)
        {
            crc |= 0x0001;
        }
        
        if (msb)
        {
            crc ^= poly;
        }
    }
    
    return crc;
}


@end
