//
//  BmobMessage.h
//  BmobSDK
//
//  Created by limao on 15/5/29.
//  Copyright (c) 2015年 donson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BmobConfig.h"

@interface BmobMessage : NSObject
+ (void)requestSMSCodeInBackgroundWithPhoneNumber:(NSString*)number
                                      andTemplate:(NSString*)templateStr
                                      resultBlock:(BmobIntegerResultBlock)block;

+ (void)verifySMSCodeInBackgroundWithPhoneNumber:(NSString*)number andSMSCode:(NSString*)code resultBlock:(BmobBooleanResultBlock)block;

+ (void)querySMSCodeStateInBackgroundWithSMSId:(unsigned)smsId resultBlock:(BmobQuerySMSCodeStateResultBlock)block;

@end
