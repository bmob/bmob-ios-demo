//
//  Bmob.h
//  BmobSDK
//
//  Created by Bmob on 13-7-31.
//  Copyright (c) 2013年 Bmob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

//包含头文件
#import "BmobSMS.h"


/**
 *  初始化成功的通知
 */
extern NSString *const  kBmobInitSuccessNotification;

/**
 *  初始化失败的通知
 */
extern NSString *const  kBmobInitFailNotification;

@interface Bmob : NSObject


/**
 *	向Bmob注册应用
 *
 *	@param	appKey	在网站注册的appkey
 */
+(void)registerWithAppKey:(NSString*)appKey;


/**
 *  得到服务器时间戳 ,需要在子线程调用
 *
 *  @return 时间戳字符串 (到秒)
 */
+(NSString*)getServerTimestamp;

/**
 *  异步调用获取服务器时间戳的方法
 *
 *  @param completion 时间戳字符串和错误信息
 */
+(void)serverTimestamp:(void(^)(NSString *timestamp,NSError *error))completion;


/**
 *  在应用进入前台是调用
 */
+(void)activateSDK;

//重新设置请求域名
+ (void)resetDomain:(NSString *)url;

#pragma mark - 配置

/**
 *  设置接口请求超时时间
 *
 *  @param seconds 多少秒
 */
+(void)setBmobRequestTimeOut:(CGFloat)seconds;

/**
 *  设置文件分块上传大小，不可小于100kb, 不超过5M
 *
 *  @param blockSize 块大小 单位 字节
 */

# pragma mark - 获取表结构


//可删除
typedef void (^BmobRegisterWithAppKeyBlock)(BOOL isSuccessful);

+(void)registerWithAppKey:(NSString *)appKey block:(BmobRegisterWithAppKeyBlock)block;



@end
