//
//  FJAudioSessionHelper.m
//  FloJack
//
//  Created by John Bullard on 4/8/13.
//  Copyright (c) 2013 John Bullard. All rights reserved.
//

#import "FJAudioSessionHelper.h"

@implementation FJAudioSessionHelper


+(NSString*)formatOSStatus:(OSStatus)error {
    char str[7];
    
    // see if it appears to be a 4-char-code
    *(UInt32 *)(str + 1) = CFSwapInt32HostToBig(error);
    if (isprint(str[1]) && isprint(str[2]) && isprint(str[3]) && isprint(str[4])) {
        str[0] = str[5] = '\'';
        str[6] = '\0';
    } else
        // no, format it as an integer
        sprintf(str, "%d", (int)error);
    return [NSString stringWithCString:str encoding:NSASCIIStringEncoding];
}

@end
