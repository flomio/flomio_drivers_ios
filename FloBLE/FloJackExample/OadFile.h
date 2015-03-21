//
//  OadFile.h
//  FlobleOSX
//
//  Created by Chuck Carter on 2/25/15.
//  Copyright (c) 2015 Flomio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MacTypes.h>


#define HAL_FLASH_WORD_SIZE 4
#define OAD_IMG_ID_SIZE       4 // Image Identification size
#define OAD_IMG_HDR_SIZE      ( 2 + 2 + OAD_IMG_ID_SIZE )// Image header size (version + length + image id size)

// The Image is transporte in 16-byte blocks in order to avoid using blob operations.
#define OAD_BLOCK_SIZE        16
#define OAD_BLOCKS_PER_PAGE  (HAL_FLASH_PAGE_SIZE / OAD_BLOCK_SIZE)
#define OAD_BLOCK_MAX        (OAD_BLOCKS_PER_PAGE * OAD_IMG_D_AREA)

#define OAD_IMG_CRC_OSET      0x0000
#if defined FEATURE_OAD_SECURE
#define OAD_IMG_HDR_OSET      0x0000
#else  // crc0 is calculated and placed by the IAR linker at 0x0, so img_hdr_t is 2 bytes offset.
#define OAD_IMG_HDR_OSET      0x0000
#endif

#define HI_UINT16(a) (((a) >> 8) & 0xff)
#define LO_UINT16(a) ((a) & 0xff)

typedef struct {
    UInt16 crc0;       // CRC must not be 0x0000 or 0xFFFF.
    UInt16 crc1;       // CRC-shadow must be 0xFFFF.
    // User-defined Image Version Number - default logic uses simple a '!=' comparison to start an OAD.
    UInt16 ver;
    UInt16 len;        // Image length in 4-byte blocks (i.e. HAL_FLASH_WORD_SIZE blocks).
    UInt8  uid[4];     // User-defined Image Identification bytes.
    UInt8  res[4];     // Reserved space for future use.
} oad_img_hdr_t;       // definition of header block in OAD image

typedef NS_ENUM(NSUInteger, imageType)
{
    imageAtype = 0,
    imageBtype = 1,
    undefinedType
};

@protocol OadFileDelegate
@required
- (void)writeBlockToOadImageIdentify:(NSData*)block;
- (void)writeBlockToOadBlockTransfer:(NSData*)block;
@optional
- (void)endOfUploadNotification;
- (void)cancelationOfUploadNotification;
- (void)connectionLostNotification;
@end

@interface OadFile : NSObject
{
    imageType currentImageType;
    NSString * currentFirmwareVersion;

    imageType oadImageType;
    NSMutableString * oadFileName;
    NSData * oadData;
    NSInteger oadDataLength;
    oad_img_hdr_t oadImageHeader;
    BOOL isUploadInProgress;
    BOOL canceled;
    BOOL uploadComplete;
    BOOL hasValidFile;
    BOOL isConnected;
    NSInteger index;
    NSInteger pNextIndex;
    NSInteger bytesToSend;
    NSInteger bytesSent;
    NSInteger blocksToSend;
    NSInteger blocksSent;
}
@property (strong, nonatomic) NSString * currentFirmwareVersion;
@property (strong, nonatomic) NSMutableString * oadFileName;
@property (strong, nonatomic) NSData * oadData;
@property (assign, nonatomic) NSInteger oadDataLength;
@property (assign, nonatomic) imageType currentImageType;
@property (assign, nonatomic) imageType oadImageType;
@property (assign, nonatomic) oad_img_hdr_t oadImageHeader;
@property (assign, nonatomic) BOOL isUploadInProgress;
@property (assign, nonatomic) BOOL canceled;
@property (assign, nonatomic) BOOL uploadComplete;;
@property (assign, nonatomic) BOOL hasValidFile;
@property (assign, nonatomic) BOOL isConnected;
@property (assign, nonatomic) NSInteger index;
@property (assign, nonatomic) NSInteger pNextIndex;
@property (assign, nonatomic) NSInteger bytesToSend;
@property (assign, nonatomic) NSInteger bytesSent;
@property (assign, nonatomic) NSInteger blocksToSend;
@property (assign, nonatomic) NSInteger blocksSent;
@property (assign, nonatomic) NSInteger oadImageNBlocks;
@property (assign, nonatomic) NSInteger oadImageNBytes;

@property id<OadFileDelegate> delegate;

- (id)init;
- (id)initWithDelegate:(id<OadFileDelegate>)oadFileDelegate;
- (void)extractImageHeader;
- (void)clearImageHeader;
- (NSData*)getOadHeaderBlock;
- (NSData*)getOadDataBlockAtIndex:(NSInteger)index;
- (bool)initiateUpload;
- (bool)doUpload;
- (bool)endUpload;
- (void)receivedImageBlockTransferCharacteristic:(NSData*)imageBlockCharacteristic;
- (void)receivedImageIdentifyCharacteristic:(NSData*)imageBlockCharacteristic;
- (void)resetOadFileAttributes;
- (void)resetOadUploadAttributes;
- (bool)validateImageTypes;
- (bool)establishUpload;
- (bool)requestCurrentImageType;
- (void)setConnectedState:(BOOL)connectedState;
- (void)handleWindowIsClosing;
- (bool)cancelUpload;

@end
