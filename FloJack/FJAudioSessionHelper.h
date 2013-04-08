//
//  FJAudioSessionHelper.h
//  FloJack
//
//  Created by John Bullard on 4/8/13.
//  Copyright (c) 2013 John Bullard. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FJAudioSessionHelper : NSObject

+(NSString*)formatOSStatus:(OSStatus)error;

@end
