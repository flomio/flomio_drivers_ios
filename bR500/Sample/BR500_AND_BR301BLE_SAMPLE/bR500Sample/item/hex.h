//
//  hex.h
//  bR500Sample
//
//  Created by 彭珊珊 on 16/1/21.
//  Copyright © 2016年 ftsafe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface hex : NSObject
+(NSData *)hexFromString:(NSString *)cmd;
void StrToHex(unsigned char *pbDest, char *szSrc, unsigned int dwLen);
int filterStr(char *szSrc, unsigned int dwLen);
@end
