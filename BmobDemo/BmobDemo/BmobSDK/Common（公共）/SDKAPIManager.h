//
//  SDKAPIManager.h
//  BmobSDK
//
//  Created by Bmob on 16/7/4.
//  Copyright © 2016年 donson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDKAPIManager : NSObject

+(instancetype)defaultAPIManager;


#pragma mark - 初始化,secret默认 open2.bmob.cn
-(NSString *)iniInterface:(NSString *)domain;


-(NSString *)secretInterface;


-(NSString *)interfaceWithKey:(NSString *)key;

-(NSString *)defaultServerDomain;

#pragma mark - 增删改查

-(NSString *)createInterface;

-(NSString *)updateInterface;


-(NSString *)findInterface;

-(NSString *)deleteInterface;

#pragma mark - 用户接口

-(NSString *)signupInterface;

-(NSString *)loginInterface;

-(NSString *)loginOrSignupInterface;

-(NSString *)resetInterface;

-(NSString *)emailVerifyInterface;

-(NSString *)updateUserPasswordInterface;

-(NSString *)getDevicePrivateInfo;

#pragma mark - 推送

-(NSString *)pushInterface;

#pragma mark - 短信
-(NSString *)requestSmsInterface;

-(NSString *)requestSmsCodeInterface;

-(NSString *)verifySmsCodeInterface;

-(NSString *)querySmsInterface;

-(NSString *)phoneResetInterface;

#pragma mark - BQL

-(NSString *)cloudQueryInterface;

#pragma maek - 支付

-(NSString *)payInterface;

-(NSString *)payQueryInterface;

#pragma mark - oterh

-(NSString *)timestampInterface;

-(NSString *)batchInterface;

-(NSString *)functionsInterface;

-(NSString *)tcpFileServerUrlInterfaceKeyInterface;

#pragma mark - cdn

-(NSString *)cdnInterface;

-(NSString *)saveCdnUploadInterface;

-(NSString *)delCdnFileInterface;

-(NSString *)delCdnBatchInterface;

#pragma mark - data table

-(NSString *)schemasInterface;
@end
