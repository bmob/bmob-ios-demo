//
//  UPYUNConfig.m
//  UpYunSDKDemo
//
//  Created by 林港 on 16/2/2.
//  Copyright © 2016年 upyun. All rights reserved.
//

#import "BmobUPYUNConfig.h"

@implementation BmobUPYUNConfig
+ (BmobUPYUNConfig *)sharedInstance
{
    static dispatch_once_t once;
    static BmobUPYUNConfig *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[BmobUPYUNConfig alloc] init];
        sharedInstance.DEFAULT_BUCKET = @"";
        sharedInstance.DEFAULT_PASSCODE = @"";
        sharedInstance.DEFAULT_EXPIRES_IN = 1800;
        sharedInstance.DEFAULT_EXPIRES_STRING = @"";
        sharedInstance.DEFAULT_MUTUPLOAD_SIZE = 4*1024*1024;
        sharedInstance.DEFAULT_RETRY_TIMES = 2;
        sharedInstance.SingleBlockSize = 256*1024;
        sharedInstance.FormAPIDomain = @"https://v0.api.upyun.com/";
        sharedInstance.MutAPIDomain = @"https://m0.api.upyun.com/";
    });
    return sharedInstance;
}
@end
