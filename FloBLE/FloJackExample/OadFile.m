//
//  OadFile.m
//  FlobleOSX
//
//  Created by Chuck Carter on 2/25/15.
//  Copyright (c) 2015 Flomio. All rights reserved.
//

#import "OadFile.h"

@implementation OadFile

@synthesize currentFirmwareVersion;
@synthesize oadFileName;
@synthesize oadData;
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
//    NSData* headerBlock = [NSData dataWithBytes:oadData.bytes length:sizeof(oad_img_hdr_t)];
    uint8_t headerData[OAD_IMG_HDR_SIZE + 2 + 2]; // 12Bytes
  
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
    
    
    return headerBlock;
}

- (NSData*)getOadDataBlockAtIndex:(NSInteger)theIndex
{
    NSRange blockRange;
    blockRange.length = OAD_BLOCK_SIZE;
    blockRange.location = theIndex*(OAD_BLOCK_SIZE);
    
    UInt8 oadDataStuff[2+OAD_BLOCK_SIZE];
    oadDataStuff[0] = LO_UINT16(theIndex);
    oadDataStuff[1] = HI_UINT16(theIndex);

    
    [oadData getBytes:&oadDataStuff[2] range:blockRange];
    

    NSData* dataBlock = [NSData dataWithBytes:oadDataStuff length:2+OAD_BLOCK_SIZE];
    return dataBlock;
}

- (bool)validateImageTypes
{
    if ((currentImageType == undefinedType) || (oadImageType == undefinedType))
    {
        return NO;
    }
    else
    {
        return (currentImageType != oadImageType);
    }
}

- (bool)requestCurrentImageType
{
    unsigned char data = 0x01;
    NSData* block = [NSData dataWithBytes:&data length:1];
    [delegate writeBlockToOadImageIdentify:(NSData*)block];

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
//        bytesToSend = oadDataLength;
        
        return YES;

    }
    else
    {
        // display error dialog
        NSLog(@"Failed imageTypes %2.2x %2.2x",currentImageType, oadImageType);
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
    if(![self isConnected])
    {
        [self cancelUpload];
        [delegate connectionLostNotification];
    }
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
//    self.imgVersion = ((uint16_t)data[1] << 8 & 0xff00) | ((uint16_t)data[0] & 0xff);
//    NSLog(@"self.imgVersion : %04hx",self.imgVersion);

    
    UInt8* bytes = (UInt8*)imageBlockCharacteristic.bytes;
    NSInteger version = ((uint16_t)bytes[1] << 8 & 0xff00) | ((uint16_t)bytes[0] & 0xff);
    
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
    [oadFileName setString:@"https://dl.dropboxusercontent.com/u/74911655/OAD_A.bin"];
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


@end
